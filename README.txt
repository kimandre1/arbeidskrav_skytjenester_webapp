Self-contained app package

Contents:
- index.html
- app.py
- requirements.txt
- example.json

Run locally:
1) Create and activate a Python virtual environment
2) pip install -r requirements.txt
3) python app.py
4) Open http://localhost:8000

Deploy later to App Service:
1) Create your App Service resources when ready
2) Upload the contents of this folder as your app package root
3) Use startup command: gunicorn --bind=0.0.0.0 --timeout 120 app:app
4) Set app settings: DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD

API endpoint:
- GET /api/example
This runs: SELECT * FROM example LIMIT 200
