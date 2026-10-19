from flask import Flask, render_template_string, request, redirect
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = (
    os.getenv('DB_LINK') or
    f"postgresql://{os.getenv('DB_USER', 'myuser')}:{os.getenv('DB_PASSWORD', 'mypassword')}"
    f"@{os.getenv('DB_HOST', 'localhost')}:{os.getenv('DB_PORT', '5432')}/{os.getenv('DB_NAME', 'mydatabase')}"
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)

TEMPLATE = '''
<!DOCTYPE html>
<html>
<head>
    <title>Student Portal v2</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        .container {
            max-width: 700px;
            margin: 0 auto;
        }
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 40px;
            margin-bottom: 30px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            font-size: 2em;
            margin-bottom: 8px;
        }
        .version-badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: bold;
        }
        form {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }
        input[type="text"], input[type="email"] {
            padding: 14px 18px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1em;
            transition: border-color 0.3s, box-shadow 0.3s;
        }
        input[type="text"]:focus, input[type="email"]:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.2);
        }
        button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 10px;
            font-size: 1em;
            font-weight: bold;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
        }
        .users-section h2 {
            color: #333;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .count-badge {
            background: #667eea;
            color: white;
            padding: 4px 12px;
            border-radius: 15px;
            font-size: 0.8em;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 14px;
            text-align: left;
            font-weight: 600;
        }
        th:first-child { border-radius: 10px 0 0 0; }
        th:last-child { border-radius: 0 10px 0 0; }
        td {
            padding: 14px;
            border-bottom: 1px solid #eee;
            color: #555;
        }
        tr:hover td {
            background: #f8f9ff;
        }
        .empty-state {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <div class="header">
                <h1>Student Portal</h1>
                <span class="version-badge">v2.0</span>
            </div>
            <form method="POST">
                <input type="text" name="name" placeholder="Enter your name" required>
                <input type="email" name="email" placeholder="Enter your email" required>
                <button type="submit">Register Student</button>
            </form>
        </div>

        <div class="card users-section">
            <h2>Registered Students <span class="count-badge">{{ users|length }}</span></h2>
            {% if users %}
            <table>
                <tr><th>ID</th><th>Name</th><th>Email</th></tr>
                {% for user in users %}
                <tr><td>{{ user.id }}</td><td>{{ user.name }}</td><td>{{ user.email }}</td></tr>
                {% endfor %}
            </table>
            {% else %}
            <div class="empty-state">No students registered yet. Be the first!</div>
            {% endif %}
        </div>
    </div>
</body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        user = User(name=request.form['name'], email=request.form['email'])
        db.session.add(user)
        db.session.commit()
        return redirect('/')
    users = User.query.all()
    return render_template_string(TEMPLATE, users=users)

with app.app_context():
    try:
        db.create_all()
        print("✓ Database tables created")
    except Exception as e:
        print(f"✗ Database connection failed: {e}")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

#Testing code change and scan