Ubuntu server run guide

Contents:
- index.html
- app.py
- requirements.txt
- example.json

Install and run on Ubuntu:
1) sudo apt update
2) sudo apt install -y python3 python3-venv python3-pip
3) python3 -m venv .venv
4) source .venv/bin/activate
5) pip install -r requirements.txt

Set database environment variables (default host is already 10.10.0.99):
1) export DB_HOST=10.10.0.99
2) export DB_PORT=3306
3) export DB_NAME=exampledb
4) export DB_USER=appuser
5) export DB_PASSWORD='change-me'

Run with Gunicorn (recommended):
1) gunicorn --bind 0.0.0.0:8000 --workers 2 --timeout 120 app:app

Test endpoint:
- GET /api/example
	Runs: SELECT * FROM example LIMIT 200
