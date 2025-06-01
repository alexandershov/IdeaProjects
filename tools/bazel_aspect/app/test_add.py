import pytest


@pytest.mark.parametrize(
    "x, y",
    [
        (1, 2, 3),
        (3, 2, 5),
    ],
)
def test_add(x, y, expected):
    assert x + y == expected
