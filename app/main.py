from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import random
import time
from typing import List

app = FastAPI(title="Dice Roller Game API")

class RollRequest(BaseModel):
    username: str
    guess: int  # Le nombre deviné par l'utilisateur (1-6)

class RollResponse(BaseModel):
    username: str
    dice_roll: int
    result: str  # "WON" ou "LOST"
    round: int

# État du jeu (en mémoire, pour l'exemple)
game_state = {
    "results": [],
    "round": 0
}

@app.post("/start", response_model=dict)
async def start_game(username: str):
    """Démarre une nouvelle partie."""
    game_state["results"] = []
    game_state["round"] = 0
    return {"message": f"Welcome, {username}! Game started. Use `/roll` to play."}

@app.post("/roll", response_model=RollResponse)
async def roll_dice(request: RollRequest):
    """Joue un tour : l'utilisateur devine un nombre, le dé est lancé."""
    if request.guess < 1 or request.guess > 6:
        raise HTTPException(status_code=400, detail="Guess must be between 1 and 6.")

    game_state["round"] += 1
    dice_roll = random.randint(1, 6)
    result = "WON" if request.guess == dice_roll else "LOST"
    game_state["results"].append({
        "round": game_state["round"],
        "dice_roll": dice_roll,
        "result": result
    })

    return {
        "username": request.username,
        "dice_roll": dice_roll,
        "result": result,
        "round": game_state["round"]
    }

@app.get("/results", response_model=List[dict])
async def get_results():
    """Retourne l'historique des résultats."""
    return game_state["results"]

@app.get("/health")
async def health_check():
    return {"status": "ok"}

:
# curl -X POST "http://localhost:8000/start" -H "Content-Type: application/json" -d '{"username":"Arthur"}'
# curl -X POST "http://localhost:8000/roll" -H "Content-Type: application/json" -d '{"username":"Arthur","guess":3}'
