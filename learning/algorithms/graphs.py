import collections
import heapq
import math

import pytest

GRAPH = {
    'a': ['b', 'c'],
    'b': ['a', 'c', 'd'],
    'd': ['a', 'e'],
}

WEIGHTED_GRAPH = {
    'a': [('b', 1), ('c', 8), ('d', 9)],
    'b': [('c', 4)],
    'c': [('a', 2), ('d', 3)],
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


# proof:
# let v be the node at the top of the heap
# let's prove that d[v] is the minimum distance from start to v.
# induction by k, where k is the number of visited nodes
# it obviously holds for k = 0, since top of the heap at 0 is start itself
# let it hold for k, and let's prove for k + 1
# let node v be the top of the heap
# consider min_path(start, v)
# let's split this path into two parts: first part contains only visited nodes (it contains at least start)
# second part starts with not visited nodes.
# the second part contains at least v. Let the last node of the first part be `p` and `q` be the first node of
# the second part
# if a -> b -> c -> d minimum path from a to d, then a -> b -> c minimum path from a to c
# min_distance(start, q) == d[q]
# since we visited p and did relaxation, this means that d[q] == min_distance(start, q)
# since v is top of the heap, this means that d[v] <= d[q]
# d[v] <= d[q] = min_distance(start, q) <= min_distance(start, v)
# d[v] <= min_distance(start, v), since our algorithm can't find distance that is less than min_distance, then
# d[v] == min_distance(start, v)
def dijkstra(graph, start, goal):
    # dijkstra is essentially bfs, but with a heap instead of queue
    # and a dictionary of distances
    distances = collections.defaultdict(lambda: math.inf)
    frontier = [(start, 0)]
    distances[start] = 0
    while frontier:
        node, distance = heapq.heappop(frontier)
        if node == goal:
            # dijkstra is a greedy algorithm as soon as we get to goal
            # we got a shorter distance
            return distance
        for neighbour, weight in graph.get(node, []):
            new_distance = distance + weight
            if new_distance < distances[neighbour]:
                distances[neighbour] = new_distance
                heapq.heappush(frontier, (neighbour, new_distance))
    return distances[goal]


@pytest.mark.parametrize("graph,start,goal,expected_distance", [
    (WEIGHTED_GRAPH, 'a', 'd', 8),
    (WEIGHTED_GRAPH, 'a', 'b', 1),
    (WEIGHTED_GRAPH, 'a', 'c', 5),
])
def test_dijkstra(graph, start, goal, expected_distance):
    assert dijkstra(graph, start, goal) == expected_distance
