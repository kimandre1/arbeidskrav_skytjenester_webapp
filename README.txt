Ubuntu server run guide

Contents:
- index.html
- app.py
- requirements.txt
- example.json

Install and run on Ubuntu:
1) chmod +x install.sh
2) ./install.sh

Optional override if needed:
- DB_HOST=10.10.0.99 DB_PORT=3306 DB_NAME=exampledb DB_USER=testuser DB_PASSWORD='StrongPassword!' ./install.sh

Run with Gunicorn (recommended):
1) ./start.sh

Test endpoint:
- GET /api/example
	Runs: SELECT * FROM example LIMIT 200
