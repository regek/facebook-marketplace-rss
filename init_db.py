# Copyright (c) 2024, regek
# All rights reserved.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. 

import sqlite3

# Connect to the SQLite database (it will be created if it doesn't exist)
conn = sqlite3.connect('fb-rss-feed.db')

# Create a cursor object using the cursor() method
cursor = conn.cursor()

# Create tables
cursor.execute('''
CREATE TABLE IF NOT EXISTS webpage_changes (
    url TEXT PRIMARY KEY,
    last_hash TEXT,
    last_checked DATETIME
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS ad_changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    url TEXT NOT NULL,
    ad_id TEXT NOT NULL UNIQUE,
    title TEXT,
    price TEXT,
    last_checked DATETIME
);

''')

# Commit the changes and close the connection
conn.commit()
conn.close()

print("Database initialized.")

