import os

from flask import Flask, jsonify, send_from_directory
import pymysql

app = Flask(__name__, static_folder='.')

# Test-only database settings.
DB_CONFIG = {
    'host': '10.10.0.99',
    'port': 3306,
    'user': 'appuser',
    'password': 'change-me',
    'database': 'exampledb',
}


def _db_config() -> dict:
    return {
        'host': DB_CONFIG['host'],
        'port': DB_CONFIG['port'],
        'user': DB_CONFIG['user'],
        'password': DB_CONFIG['password'],
        'database': DB_CONFIG['database'],
        'cursorclass': pymysql.cursors.DictCursor,
        'connect_timeout': 5,
        'read_timeout': 10,
        'write_timeout': 10,
    }


@app.get('/')
def home():
    return send_from_directory('.', 'index.html')


@app.get('/example.json')
def sample_data():
    return send_from_directory('.', 'example.json')


@app.get('/api/example')
def get_example_table():
    config = _db_config()

    query = 'SELECT * FROM example LIMIT 200'

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
