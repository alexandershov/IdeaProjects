import pytest


def binary_search(seq, value):
    start = 0
    end = len(seq)
    # [start, end) shrinks at every iteration
    while start < end:
        mid = (start + end) // 2
        if seq[mid] == value:
            return mid
        elif seq[mid] > value:
            end = mid
        else:
            start = mid + 1
    return -1


@pytest.mark.parametrize('items, value, expected', [
    ('abcde', 'f', -1),
    ('abcde', 'a', 0),
    ('abcde', 'b', 1),
    ('abcde', 'c', 2),
    ('abcde', 'd', 3),
    ('abcde', 'e', 4),
])
def test_binary_search(items, value, expected):
    assert binary_search(items, value) == expected
