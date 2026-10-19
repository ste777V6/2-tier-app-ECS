import os
import sys

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from app import app  # adjust if your module or variable has a different name


def test_app_exists():
    assert app is not None


def test_home_page_responds():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code in (200, 302)  # 302 if / redirects to a login page