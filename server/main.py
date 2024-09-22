import asyncio
import os
import json
from fastapi import FastAPI, HTTPException

# This line sets a compatible event loop for Windows
if os.name == 'nt':
    asyncio.set_event_loop_policy(asyncio.WindowsSelectorEventLoopPolicy())

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/scan/")
def scan(url: str):
    target_url = url

    wapiti_command = f"wapiti -u {target_url} -f json -o ./wapiti_report.json"
    os.system(wapiti_command)

    try:
        with open("wapiti_report.json", "r") as file:
            wapiti_results = json.load(file)
        return wapiti_results

    except FileNotFoundError:
        raise HTTPException(status_code=500, detail="Wapiti report not found.")
    
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Failed to parse Wapiti report.")