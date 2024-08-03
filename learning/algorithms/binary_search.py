import pytest


def binary_search(seq, value):
    start = 0
    end = len(seq)
    # [start, end) shrinks at every iteration
    # invariant is that we're not interested in items < start and in items >= end
    while start < end:
        mid = (start + end) // 2
        if seq[mid] == value:
            return mid
        elif seq[mid] > value:
            end = mid
        else:
            start = mid + 1
    return -1


def binary_search_left(seq, value):
    """
    Return index of first occurrence of value in seq.
    If value is not in seq, return index where value would be located after insertion
    """
    start = 0
    end = len(seq)
    # invariants are:
    # * everything after and including `end` is >= value
    # * everything before start is < value
    while start < end:
        mid = (start + end) // 2
        if seq[mid] >= value:
            end = mid
        else:
            start = mid + 1
    # at the end start == end
    # invariants are still valid at this point,
    # so everything after and including end is >= value
    # everything before start (== end) is < value
    # this means that end (== start) index is the first where we have >= value
    # if value is in seq, then start is the index of first occurrence
    # if value is not in seq, then start is the first index that is > value
    # this means that start is index of value after insertion
    return start


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


@pytest.mark.parametrize('items, value, expected', [
    ('abbbde', ' ', 0),
    ('abbbde', 'a', 0),
    ('abbbde', 'b', 1),
    ('abbbde', 'c', 4),
    ('abbbde', 'f', 6),
])
def test_binary_search_left(items, value, expected):
    assert binary_search_left(items, value) == expected
