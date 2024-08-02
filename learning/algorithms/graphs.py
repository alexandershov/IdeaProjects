import collections

import pytest

GRAPH = {
    'a': ['b', 'c'],
    'b': ['a', 'c', 'd'],
    'd': ['e', 'a'],
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
def bfs_recursive(graph, start, visit, visited=None):
    if visited is None:
        visited = {start}
    if isinstance(start, str):
        level = [start]
    else:
        level = start

    next_level = []
    for node in level:
        visit(node)
        for child in graph.get(node, []):
            if child in visited:
                continue
            visited.add(child)
            next_level.append(child)
    if next_level:
        bfs_recursive(graph, next_level, visit, visited)


@pytest.fixture(params=[bfs, bfs_recursive])
def algorithm(request):
    return request.param


@pytest.mark.parametrize("graph,start,expected", [
    (GRAPH, 'a', ['a', 'b', 'c', 'd', 'e']),
    (GRAPH, 'b', ['b', 'a', 'c', 'd', 'e']),
    (GRAPH, 'c', ['c']),
    (GRAPH, 'd', ['d', 'e', 'a', 'b', 'c']),
    (GRAPH, 'e', ['e']),
])
def test_bfs(graph, start, expected, algorithm):
    visited = []
    algorithm(graph, start, visited.append)
    assert visited == expected
