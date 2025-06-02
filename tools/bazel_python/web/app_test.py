# TODO: why it's not added to deps by gazelle?
import pyspark

# TODO: understand why this import works (why `app` directory is in path)?
from web import add


def test_add():
    assert add.add(2, 2) == 4
