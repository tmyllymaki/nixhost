#!/usr/bin/env python

import os
from flask import Flask, render_template, jsonify
import sqlite3

app = Flask(__name__)

# Get the SQLite database path from environment variable
db_path = os.environ.get('DB_PATH', '../inventory.sqlite')

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/timeseries')
def get_data():
    # Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Query the database to get total value of the inventory over time
    cursor.execute('SELECT date, SUM(price * amount) FROM inventory GROUP BY date order by date desc')
    data = cursor.fetchall()

    # Close the database connection
    conn.close()

    # Convert the data to JSON format
    json_data = [{'date': row[0], 'total_value': row[1]} for row in data]

    return jsonify(json_data)

# Show current inventory
@app.route('/inventory')
def get_inventory():
    # Connect to the SQLite database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Query the database to get the inventory data
    cursor.execute('SELECT item, price, amount FROM inventory where date = (select max(date) from inventory) order by price * amount desc')
    data = cursor.fetchall()

    # Close the database connection
    conn.close()

    # Convert the data to JSON format
    json_data = [{'item': row[0], 'price': row[1], 'amount': row[2]} for row in data]

    return jsonify(json_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)