import os
from pathlib import Path

from flask import Flask, jsonify, send_from_directory
import pymysql

BASE_DIR = Path(__file__).resolve().parent

app = Flask(__name__, static_folder=str(BASE_DIR), static_url_path='')

def _env_int(name: str, default: int) -> int:
    value = os.getenv(name)
    if value is None:
        return default
    try:
        return int(value)
    except ValueError:
        return default


def _db_config() -> dict:
    # Defaults target the Ubuntu-accessible database at 10.10.0.99.
    host = os.getenv('DB_HOST', '10.10.0.99')
    port = _env_int('DB_PORT', 3306)
    user = os.getenv('DB_USER', 'appuser')
    password = os.getenv('DB_PASSWORD', 'change-me')
    database = os.getenv('DB_NAME', 'exampledb')

    return {
        'host': host,
        'port': port,
        'user': user,
        'password': password,
        'database': database,
        'cursorclass': pymysql.cursors.DictCursor,
        'connect_timeout': 5,
        'read_timeout': 10,
        'write_timeout': 10,
    }


@app.get('/')
def home():
    return send_from_directory(str(BASE_DIR), 'index.html')


@app.get('/example.json')
def sample_data():
    return send_from_directory(str(BASE_DIR), 'example.json')


@app.get('/api/example')
def get_example_table():
    config = _db_config()

    query = 'SELECT * FROM example LIMIT 200'
    connection = None

    try:
        connection = pymysql.connect(**config)
        with connection.cursor() as cursor:
            cursor.execute(query)
            rows = cursor.fetchall()
    except Exception as exc:
        return jsonify({'error': f'Failed to query table "example": {exc}'}), 500
    finally:
        try:
            connection.close()
        except Exception:
            pass

    return jsonify({'rows': rows})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.getenv('PORT', '8000')))
