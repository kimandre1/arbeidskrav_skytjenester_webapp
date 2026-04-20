#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

if ! command -v apt-get >/dev/null 2>&1; then
  echo "This install script is intended for Ubuntu/Debian systems (apt-get required)."
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is not installed. Installing dependencies with apt-get..."
fi

echo "Installing OS packages..."
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip default-mysql-client

echo "Creating virtual environment (.venv) if needed..."
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

# shellcheck disable=SC1091
source .venv/bin/activate

echo "Installing Python dependencies..."
python -m pip install --upgrade pip
pip install -r requirements.txt

DB_HOST="${DB_HOST:-10.10.0.99}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-exampledb}"
DB_USER="${DB_USER:-testuser}"
DB_PASSWORD="${DB_PASSWORD:-StrongPassword!}"

echo "Writing environment file (.app_env)..."
cat > .app_env <<EOF
export DB_HOST='${DB_HOST}'
export DB_PORT='${DB_PORT}'
export DB_NAME='${DB_NAME}'
export DB_USER='${DB_USER}'
export DB_PASSWORD='${DB_PASSWORD}'
EOF
chmod 600 .app_env

echo "Importing exampledb.sql with mysql..."
MYSQL_PWD="$DB_PASSWORD" mysql \
  --host="$DB_HOST" \
  --port="$DB_PORT" \
  --user="$DB_USER" \
  --protocol=TCP < exampledb.sql

echo "Writing startup script (start.sh)..."
cat > start.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# shellcheck disable=SC1091
source .venv/bin/activate
# shellcheck disable=SC1091
source .app_env

exec gunicorn --bind 0.0.0.0:8000 --workers 2 --timeout 120 app:app
EOF
chmod +x start.sh

echo "Installation completed."
echo "Start app with: ./start.sh"
