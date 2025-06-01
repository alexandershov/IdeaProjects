# TODO: understand why this import works (why `app` directory is in path)?
from app import add

def test_add():
    assert add.add(2, 2) == 4
