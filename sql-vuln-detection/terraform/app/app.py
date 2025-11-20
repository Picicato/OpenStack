from flask import Flask, request, render_template
import os
import psycopg2
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# DB config
PG_HOST = os.getenv("PG_HOST", "postgres")
PG_DB = os.getenv("PG_DB", "test")
PG_USER = os.getenv("PG_USER", "test")
PG_PASS = os.getenv("PG_PASS", "test")

# SQL Injection detection metric
sql_injection_attempts = Counter(
    "sql_injection_attempts_total",
    "Number of detected SQL injection attempts"
)

# SQL injection patterns
INJECTION_PATTERNS = [
    "' OR 1=1 --",
    "' OR '1'='1",
    "' OR 1=1#",
    "' OR 1=1/*",
    "--",
    "; DROP",
    " OR ",
]

def detect_sqli(payload):
    payload = payload.lower()
    for pattern in INJECTION_PATTERNS:
        if pattern.lower() in payload:
            return True
    return False


def get_conn():
    conn = psycopg2.connect(
        host=PG_HOST, database=PG_DB, user=PG_USER, password=PG_PASS
    )
    return conn

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/login", methods=["POST"])
def login():
    username = request.form.get("username", "")
    password = request.form.get("password", "")

    # Detect SQL injection attempt
    full_payload = username + " " + password
    if detect_sqli(full_payload):
        sql_injection_attempts.inc()

    conn = get_conn()
    cur = conn.cursor()

    # vulnerable SQL
    query = f"SELECT id, username FROM users WHERE username='{username}' AND password='{password}'"

    try:
        cur.execute(query)
        rows = cur.fetchall()
        if rows:
            return f"Welcome, {rows[0][1]}!"
        else:
            return "Unauthorized", 401
    except Exception as e:
        return f"DB error: {e}", 500
    finally:
        cur.close()
        conn.close()

# Prometheus metrics endpoint
@app.route("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
