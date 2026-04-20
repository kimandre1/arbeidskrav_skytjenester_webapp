# Arbeidskrav Skytjenester - Web App

## Overview
This is a Flask-based web application that displays MySQL table data via a REST API. The app serves an HTML interface that queries the backend `/api/example` endpoint to fetch and render rows from the `example` table in a MySQL database running on a remote host.

## Prerequisites
**IMPORTANT:** Infrastructure must be provisioned before deploying this application.

Run the infrastructure setup first:
```
https://github.com/kimandre1/arbeidskrav_skytjenester
```

This will create:
- Azure resources (VMs, networking, NSGs, etc.)
- MySQL database server accessible at 10.10.0.99:3306
- Network configuration to allow app server access to database

## Contents
- `app.py` - Flask application with /api/example endpoint
- `index.html` - Frontend UI displaying table data
- `install.sh` - Automated setup script for Ubuntu servers
- `exampledb.sql` - Database schema and sample data
- `requirements.txt` - Python dependencies (Flask, gunicorn, PyMySQL)

## Installation on Ubuntu Server

### Quick Start
```bash
chmod +x install.sh
./install.sh
```

The install script will:
1. Install OS packages (python3, venv, pip, mysql-client)
2. Create Python virtual environment
3. Install Python dependencies
4. Configure database environment variables
5. Import database schema and sample data using exampledb.sql
6. Create start.sh launcher script

### Custom Database Configuration
If your MySQL database uses different credentials, override environment variables:
```bash
DB_HOST=10.10.0.99 \
DB_PORT=3306 \
DB_NAME=exampledb \
DB_USER=testuser \
DB_PASSWORD='StrongPassword!' \
./install.sh
```

Default values:
- DB_HOST: 10.10.0.99
- DB_PORT: 3306
- DB_NAME: exampledb
- DB_USER: testuser
- DB_PASSWORD: StrongPassword!

## Running the Application

Start the web server with Gunicorn:
```bash
./start.sh
```

This binds to `0.0.0.0:8000` and uses 2 workers with 120s timeout.

Open your browser and navigate to:
```
http://<server-ip>:8000/
```

## API Endpoints

### GET /
Returns the HTML interface (index.html).

### GET /api/example
Returns JSON array of rows from the `example` table.

Response format:
```json
{
  "rows": [
    {
      "id": 1,
      "name": "Alice",
      "email": "alice@example.local",
      "role": "admin"
    }
  ]
}
```

### GET /example.json
Returns static example JSON file (fallback for testing).

## Testing

### Local Test (from server)
```bash
curl http://127.0.0.1:8000/
curl http://127.0.0.1:8000/api/example
```

### Remote Test
```bash
curl http://20.251.8.248:8000/api/example
```

### Browser Test
Visit: `http://<public-ip>:8000/`

Click "Reload" button to fetch data from the API.

## Troubleshooting

### Connection Refused
- Check if Gunicorn is running: `ps aux | grep gunicorn`
- Check if port 8000 is listening: `sudo ss -ltnp | grep :8000`
- Verify Azure NSG allows inbound TCP 8000

### Database Connection Error
- Verify database is accessible: `mysql -h 10.10.0.99 -u testuser -p`
- Check environment variables: `cat .app_env`
- Verify credentials match database server configuration

### Import Failed
- Ensure mysql-client is installed: `which mysql`
- Check exampledb.sql exists in project root
- Verify database user has CREATE/INSERT permissions

## Production Notes
- Use environment variables for sensitive credentials (DB_PASSWORD, etc.)
- Consider using a process manager (systemd service) for auto-restart
- Configure firewall/NSG rules for network isolation
- Use reverse proxy (nginx) in production for SSL/TLS
- Monitor logs for performance issues

## Files Generated at Runtime
- `.venv/` - Python virtual environment
- `.app_env` - Environment configuration (contains credentials)
- `start.sh` - Startup launcher script
- Gunicorn process logs
