import collections

import pytest

GRAPH = {
    'a': ['b', 'c'],
    'b': ['a', 'c', 'd'],
    'd': ['a', 'e'],
}


def bfs(graph, start, visit):
    visited = {start}
    queue = collections.deque([start])
    while queue:
        node = queue.popleft()
        visit(node)
        for node in graph.get(node, []):
            if node in visited:
                # if node is visited, then it's already in a queue
                # and we can skip it
                continue
            visited.add(node)
            queue.append(node)


# the way to think about bfs is that we have a current level,
# and we generate the next level based on current level
# it's essentially corecursion, kinda like when we start with 1, 1 and generated fibonachi numbers from here
def bfs_recursive(graph, start, visit, enqueued=None):
    if enqueued is None:
        enqueued = {start}
    if isinstance(start, str):
        level = [start]
    else:
        level = start

    next_level = []
    for node in level:
        visit(node)
        for child in graph.get(node, []):
            if child in enqueued:
                continue
            enqueued.add(child)
            next_level.append(child)
    if next_level:
        bfs_recursive(graph, next_level, visit, enqueued)


@pytest.fixture(params=[bfs, bfs_recursive])
def bfs_algorithm(request):
    return request.param


@pytest.mark.parametrize("graph,start,expected", [
    (GRAPH, 'a', ['a', 'b', 'c', 'd', 'e']),
    (GRAPH, 'b', ['b', 'a', 'c', 'd', 'e']),
    (GRAPH, 'c', ['c']),
    (GRAPH, 'd', ['d', 'a', 'e', 'b', 'c']),
    (GRAPH, 'e', ['e']),
])
def test_bfs(graph, start, expected, bfs_algorithm):
    visited = []
    bfs_algorithm(graph, start, visited.append)
    assert visited == expected


def dfs(graph, start, visit):
    visited = set()
    # compared to bfs we're using stack instead of a queue
    stack = [start]
    while stack:
        node = stack.pop()
        if node in visited:
            continue
        visit(node)
        visited.add(node)
        stack.append(node)
        for child in reversed(graph.get(node, [])):
            # compared to bfs, we don't add `child` to `visited` here,
            # because we can reach child with another path
            stack.append(child)


def dfs_recursive(graph, start, visit, visited=None):
    if visited is None:
        visited = set()

    if start in visited:
        return
    visit(start)
    visited.add(start)
    for child in graph.get(start, []):
        dfs_recursive(graph, child, visit, visited)


@pytest.fixture(params=[dfs, dfs_recursive])
def dfs_algorithm(request):
    return request.param


@pytest.mark.parametrize("graph,start,expected", [
    (GRAPH, 'a', ['a', 'b', 'c', 'd', 'e']),
    (GRAPH, 'b', ['b', 'a', 'c', 'd', 'e']),
    (GRAPH, 'c', ['c']),
    (GRAPH, 'd', ['d', 'a', 'b', 'c', 'e']),
    (GRAPH, 'e', ['e']),
])
def test_dfs(graph, start, expected, dfs_algorithm):
    visited = []
    dfs_algorithm(graph, start, visited.append)
    assert visited == expected
