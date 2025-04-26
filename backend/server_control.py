import os
import subprocess
import logging
import re
import psutil
import threading
import time
from fastapi import FastAPI
import uvicorn

# === FastAPI App ===
app = FastAPI()
BASE_DIR = "c:/swds/servers"
server_processes = {}

# === Logger ===
logger = logging.getLogger("server_control")
logger.setLevel(logging.INFO)
console = logging.StreamHandler()
console.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))
logger.addHandler(console)

# === Server Logic ===
def find_all_server_folders():
    return sorted(
        int(name.replace("server", ""))
        for name in os.listdir(BASE_DIR)
        if re.fullmatch(r"server\d+", name) and os.path.isdir(os.path.join(BASE_DIR, name))
    )

def terminate_process_tree(pid):
    try:
        proc = psutil.Process(pid)
        for child in proc.children(recursive=True):
            child.terminate()
        proc.terminate()
        proc.wait()
        logger.info(f"Killed process tree with PID {pid}")
    except Exception as e:
        logger.error(f"Failed to kill process tree: {e}")

def control_server(server_number: int, action: str):
    folder = f"server{server_number}"
    path = os.path.join(BASE_DIR, folder)
    exe = os.path.join(path, "server64.exe")
    config = os.path.join(path, "config_data")

    if not os.path.isdir(path):
        msg = f"Folder '{folder}' not found."
        logger.warning(msg)
        return msg

    if action == "start":
        if server_number in server_processes:
            msg = f"Server {server_number} already running."
            logger.info(msg)
            return msg
        if not os.path.exists(exe):
            msg = f"server64.exe not found in {path}"
            logger.error(msg)
            return msg
        proc = subprocess.Popen(
            ["cmd", "/K", exe, "+server_dir", config],
            cwd=path,
            creationflags=subprocess.CREATE_NEW_CONSOLE
        )
        server_processes[server_number] = proc
        msg = f"Started server{server_number}"
        logger.info(msg)
        return msg

    elif action == "stop":
        proc = server_processes.get(server_number)
        if not proc:
            msg = f"Server {server_number} is not running."
            logger.info(msg)
            return msg
        terminate_process_tree(proc.pid)
        del server_processes[server_number]
        msg = f"Stopped server{server_number}"
        logger.info(msg)
        return msg

    elif action == "restart":
        logger.info(f"Restarting server{server_number}")
        control_server(server_number, "stop")
        return control_server(server_number, "start")

    return "Invalid action"

def control_all_servers(action: str):
    logger.info(f"Performing '{action}' on all servers")
    results = []
    for num in find_all_server_folders():
        result = control_server(num, action)
        results.append(result)
    return results

# === FastAPI Routes ===
@app.get("/server/{server_number}/{action}")
def api_control(server_number: str, action: str):
    if server_number.lower() == "all":
        results = control_all_servers(action)
        return {"results": results}
    try:
        num = int(server_number)
        result = control_server(num, action)
        return {"result": result}
    except ValueError:
        error = "Invalid server number"
        logger.error(error)
        return {"error": error}

# === CLI ===
def cli_loop():
    print("Server CLI ready. Type: start <n>, stop <n>, restart <n>, or exit")
    while True:
        try:
            cmd = input("> ").strip().lower()
            if cmd in ["exit", "quit"]:
                break
            match = re.match(r"(start|stop|restart)\s+(all|\d+)", cmd)
            if match:
                action, target = match.groups()
                if target == "all":
                    control_all_servers(action)
                else:
                    control_server(int(target), action)

            else:
                print("Invalid command.")
        except KeyboardInterrupt:
            print("\nExiting CLI.")
            break

# === Background API Server ===
def start_api():
    uvicorn.run(app, host="127.0.0.1", port=8001, log_level="warning")

# === Main Entrypoint ===
if __name__ == "__main__":
    threading.Thread(target=start_api, daemon=True).start()
    time.sleep(1)  # Let FastAPI warm up
    cli_loop()
