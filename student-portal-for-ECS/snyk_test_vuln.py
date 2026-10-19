## SNYK TEST ONLY
#import sqlite3, subprocess
#from flask import request
#
#API_KEY = "sk_live_1234567890abcdef"  # hardcoded secret
#
#def get_user():
#    name = request.args.get("name")
#    conn = sqlite3.connect("db.sqlite")
#    return conn.execute(f"SELECT * FROM users WHERE name = '{name}'").fetchall()  # SQL injection
#
#def ping():
#    host = request.args.get("host")
#    return subprocess.check_output(f"ping -c 1 {host}", shell=True)  # command injection