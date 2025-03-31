import json

import peewee # type: ignore
from fastapi import FastAPI, HTTPException # type: ignore
from pydantic import BaseModel # type: ignore
import uvicorn # type: ignore
import logging
import os

# Configure logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

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

if __name__ == "__main__":
    logger.info("Starting FastAPI application")
    uvicorn.run(app, host="127.0.0.1", port=8000)