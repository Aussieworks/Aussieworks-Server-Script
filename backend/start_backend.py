import peewee # type: ignore
from fastapi import FastAPI, HTTPException # type: ignore
from pydantic import BaseModel # type: ignore
import uvicorn # type: ignore
import logging
import asyncio
import httpx
from functools import partial  # Import partial to pass arguments to the function

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

# Timers table
server_timers = {}

app = FastAPI()

db = peewee.SqliteDatabase('C:\Server_Stuffs\data.db')

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

@app.get("/players/playtime/post")
async def players_playtime_post(steam_id: str, playtime: int):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.playtime = playtime
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/players/playtime/get")
async def players_playtime_get(steam_id: str):
    try:
        data = Data.get(steam_id=steam_id)
        logger.debug(f"Retrieved data: {data}")
        return data.playtime
    except Exception as e:
        logger.error(f"Error retrieving data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/players/join")
async def players_join(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.joins = data.joins+1
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/players/warn")
async def players_warn(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.warns = data.warns+1
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/players/banned/post")
async def players_banned_post(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.banned = True
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))
    
@app.get("/players/unbanned/post")
async def players_banned_post(steam_id: str):
    logger.debug(f"Received data request")
    try:
        (data, _) = Data.get_or_create(steam_id=steam_id)
        data.banned = False
        data.save()
        return data.__data__
    except Exception as e:
        logger.error(f"Error creating data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/players/banned/get")
async def players_banned_get(steam_id: str):
    try:
        data = Data.get(steam_id=steam_id)
        logger.debug(f"Retrieved data: {data}")
        return data.banned
    except Exception as e:
        logger.error(f"Error retrieving data: {e}")
        raise HTTPException(status_code=400, detail=str(e))

@app.get("/heartbeat/{server_num}")
async def heartbeat(server_num: str):
    try:
        # If no timer exists for the server, create a new one
        if server_num not in server_timers or not server_timers[server_num]:
            # Create a ResettableTimer instance and pass server_num as an argument to server_restart
            server_timers[server_num] = ResettableTimer(15, server_restart, server_num)
            server_timers[server_num].start()  # Start the timer immediately
        else:
            # Reset the timer if it already exists
            server_timers[server_num].reset()
        return {"message": f"Heartbeat received for server {server_num}"}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


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
            if response.status_code == 200:
                logger.info("Server restart triggered successfully")
            else:
                logger.error(f"Failed to restart server: {response.status_code}")
        except httpx.RequestError as e:
            logger.error(f"An error occurred while making the request: {e}")

if __name__ == "__main__":
    logger.info("Starting FastAPI application")
    uvicorn.run(app, host="127.0.0.1", port=8000)
    
