import peewee # type: ignore
from fastapi import FastAPI, HTTPException # type: ignore
from pydantic import BaseModel # type: ignore
import uvicorn # type: ignore
import logging
import asyncio
import httpx
from contextlib import asynccontextmanager
import os

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Shared by both FastAPI and Discord updater
server_states = {}  # { server_num: {"tps": "0", "players": "0"} }
server_timers = {}  # { server_num: ResettableTimer }


@asynccontextmanager
async def lifespan(app: FastAPI):
    task1 = asyncio.create_task(update_discord_webhook())
    task2 = asyncio.create_task(purge_stale_servers())
    yield
    task1.cancel()
    task2.cancel()

app = FastAPI(lifespan=lifespan)

db = peewee.SqliteDatabase(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'data.db'))

class Data(peewee.Model):
    steam_id = peewee.CharField(unique=True)
    # I changed                 \/
    playtime = peewee.IntegerField(default=0)

    joins = peewee.IntegerField(default=0)

    warns = peewee.IntegerField(default=0)

    banned = peewee.BooleanField(default=False)



    class Meta:
        database = db

db.connect()
db.create_tables([Data])

class DataRequest(BaseModel):
    name: str
    value: int

@app.get("/player/playtime/post")
async def player_playtime_post(steam_id: str, playtime: int):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.playtime = playtime
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/player/playtime/get")
async def player_playtime_get(steam_id: str):
    try:
        data = Data.get(steam_id=steam_id)
        logger.debug(f"Retrieved data: {data}")
        return data.playtime
    except Exception as e:
        logger.error(f"Error retrieving data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/player/join")
async def player_join(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.joins = data.joins+1
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/player/warn")
async def player_warn(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.warns = data.warns+1
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/player/banned/post")
async def player_banned_post(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.banned = True
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/player/unbanned/post")
async def player_banned_post(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.banned = False
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/player/banned/get")
async def player_banned_get(steam_id: str):
    try:
        data = Data.get(steam_id=steam_id)
        logger.debug(f"Retrieved data: {data}")
        return data.banned
    except Exception as e:
        logger.error(f"Error retrieving data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/heartbeat/{server_num}")
async def heartbeat(server_num: int, tps: str, players: str):
    logger.debug(f"Received heartbeat from server {server_num} with TPS {tps} and player count {players}")

    try:
        update_server_data(server_num, tps, players)
        if server_num not in server_timers or not server_timers[server_num]:
            server_timers[server_num] = ResettableTimer(60, server_restart, server_num)
            server_timers[server_num].start()
        else:
            server_timers[server_num].reset()

        return {"message": f"Heartbeat received for server #{server_num}"}
    except HTTPException as e:
        raise e
    except Exception as e:
        logger.error(f"Error handling heartbeat for server {server_num}: {e}")
        raise HTTPException(status_code=500, detail="Internal Server Error")


class ResettableTimer:
    def __init__(self, delay_seconds, function, *args, **kwargs):
        self.delay = delay_seconds
        self.function = function
        self.args = args
        self.kwargs = kwargs
        self._task = None

    def start(self):
        if self._task:
            self._task.cancel()  # Cancel previous task if it exists
        self._task = asyncio.create_task(self._run_function())

    def reset(self):
        logger.info("Timer reset.")
        self.start()

    def cancel(self):
        if self._task and not self._task.done():
            self._task.cancel()

    async def _run_function(self):
        await asyncio.sleep(self.delay)  # Simulate the delay asynchronously
        await self.function(*self.args, **self.kwargs)  # Await the actual async function

async def server_restart(server):
    async with httpx.AsyncClient() as client:
        try:
            logger.info("Sending GET request to /server/all/restart")
            response = await client.get("http://localhost:8001/server/"+str(server)+"/restart")
            logger.warning(f"No heartbeat from server {server} — resetting stats.")
            if response.status_code == 200:
                logger.info("Server restart triggered successfully")
            else:
                logger.error(f"Failed to restart server: {response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"An error occurred while making the request: {e}")


# Discord bot related code
from discord_webhook import DiscordWebhook, DiscordEmbed

import time
import json
import datetime
from threading import Lock

STATE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "webhook_state.json")
SERVERS_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "servers.json")
WEBHOOK_URL = ""  # your webhook URL

def load_message_id():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            return json.load(f).get("message_id")
    return None

def save_message_id(message_id):
    with open(STATE_FILE, "w") as f:
        json.dump({"message_id": message_id}, f)

def load_servers():
    if os.path.exists(SERVERS_FILE):
        with open(SERVERS_FILE, "r") as f:
            return json.load(f).get("servers", [])
    return []
json_lock = Lock()  # Prevent simultaneous writes

def load_servers():
    if os.path.exists(SERVERS_FILE):
        with open(SERVERS_FILE, "r") as f:
            return json.load(f).get("servers", [])
    return []

def update_server_data(server_num: int, tps: str, player_count: str):
    server_states[server_num] = {
        "tps": tps,
        "players": player_count,
        "last_seen": time.time(),
        "purged": False  # new or updated heartbeat
    }

async def purge_stale_servers():
    while True:
        now = time.time()
        for server_num, state in list(server_states.items()):
            if not state.get("purged", False) and now - state.get("last_seen", 0) > 15:
                logger.warning(f"Purging server {server_num} due to inactivity.")
                state["tps"] = "0"
                state["players"] = "0"
                state["purged"] = True
        await asyncio.sleep(5)

async def update_discord_webhook():
    try:
        message_id = load_message_id()

        if not message_id:
            logger.info("No existing message found. Creating new one.")
            webhook = DiscordWebhook(url=WEBHOOK_URL, wait=True)
            embed = DiscordEmbed(title="Server Status", description="", color="008000")
            embed.set_footer(text="Initializing...")
            webhook.add_embed(embed)
            response = webhook.execute()
            message_id = response.json()["id"]
            save_message_id(message_id)
        else:
            logger.info(f"Found existing message ID: {message_id}")

        while True:
            await asyncio.sleep(30)
            servers = load_servers()
            now = datetime.datetime.now().strftime('%d/%m/%Y %H:%M')

            lines = []
            for srv in servers:
                num = srv["number"]
                name = srv["name"]
                state = server_states.get(num, {"tps": "0", "players": "0"})
                lines.append(f"**{name}**")
                lines.append(f"  *TPS:* {state['tps']}")
                lines.append(f"  *Players:* {state['players']}")
                lines.append("")

            embed = DiscordEmbed(
                title="Server Status",
                description="\n".join(lines).strip(),
                color="008000"
            )
            embed.set_footer(text=f"Last Updated: {now}")

            edit_webhook = DiscordWebhook(url=WEBHOOK_URL, id=message_id, wait=True)
            edit_webhook.embeds = [embed]
            edit_webhook.edit()

            logger.info("Updated webhook with current server list")

    except asyncio.CancelledError:
        logger.info("Webhook updater task was cancelled.")
    except Exception as e:
        logger.error(f"Error in webhook updater: {e}")

if __name__ == "__main__":
    logger.info("Starting FastAPI application")
    uvicorn.run(app, host="127.0.0.1", port=8000)
    
