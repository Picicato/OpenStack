from flask import Flask, request, render_template
import os
import psycopg2
import requests

app = Flask(__name__)

PG_HOST = os.getenv("PG_HOST", "postgres")
PG_DB = os.getenv("PG_DB", "test")
PG_USER = os.getenv("PG_USER", "test")
PG_PASS = os.getenv("PG_PASS", "test")

SQLI_DETECTOR_URL = os.getenv("SQLI_DETECTOR_URL", "http://sqli-detector:8000/log")

def get_conn():
    return psycopg2.connect(
        host=PG_HOST,
        database=PG_DB,
        user=PG_USER,
        password=PG_PASS,
    )

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/login", methods=["POST"])
def login():
    username = request.form.get("username", "")
    password = request.form.get("password", "")

    # Envoyer payload brut au détecteur
    payload = f"{username} {password}"
    try:
        requests.post(SQLI_DETECTOR_URL, json={"payload": payload}, timeout=1)
    except Exception as e:
        print(f"Detector unreachable: {e}")

    conn = get_conn()
    cur = conn.cursor()

    query = f"SELECT id, username FROM users WHERE username='{username}' AND password='{password}'"

    try:
        cur.execute(query)
        rows = cur.fetchall()
        if rows:
            return f"Welcome, {rows[0][1]}!"
        return "Unauthorized", 401
    except Exception as e:
        return f"DB error: {e}", 500
    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
