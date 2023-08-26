# 10:37 started reading
# 10:38 started thinking
# 11:28 started writing
# 11:40 it's actually quadratic algorithm in the worse case
# 11:41 trying to submit it
# 11:44 forgot to change visited in find_invitations
# 11:50 wrong answer, current idea is DSU and check the cycle lengths, handle cycle.len == 2 separately
# 13:19 continue
# 13:41 wrong approach, solution can be constructed from disconnected components, pause
# 14:11 still wrong approach, we can construct solutions in a weird way
# 14:15 thinking about completely different approach, pause
# 13:40 continue
# 14:21 TLE
# 14:35 implemented it, but the code is terrible

# ideas:
# represent everything as a graph
# dfs/bfs
# number of free spots for each employee
# sort by in_degrees
# figure out one person to include and then just construct the solution
# find cycles with len > 2 and handle cycles with len == 2 separately
# find parts of graph, start with the start of each part

import collections
from dataclasses import dataclass
from typing import Mapping

@dataclass
class Context:
    cycle_lengths: Mapping[int, int]
    two_cycle_prefix: Mapping[int, int]

class Solution:
    def maximumInvitations(self, favorite: list[int]) -> int:
        n = len(favorite)
        in_degrees = build_in_degrees(favorite)
        starting_nodes = sorted(in_degrees, key=in_degrees.__getitem__)

        result = 0
        two_cycles = {}
        all_visited = set()
        for start in starting_nodes:
            cycle_len = find_invitations(start, favorite, two_cycles, all_visited)
            result = max(result, cycle_len)
        all_visited = set()
        graph = build_graph(favorite)
        for a_node in two_cycles:
            dfs(a_node, graph, two_cycles)
        two_cycle_result = 0
        seen = set()
        for node in two_cycles:
            if node in seen:
                continue
            next_node = favorite[node]
            seen.add(node)
            seen.add(next_node)
            two_cycle_result += 2 + two_cycles.get(node, 0) + two_cycles.get(next_node, 0)
        return max(result, two_cycle_result)




def build_in_degrees(favorite):
    in_degrees = dict.fromkeys(range(len(favorite)), 0)
    for fav in favorite:
        in_degrees[fav] += 1
    return in_degrees


def find_invitations(node, favorite, two_cycles, all_visited):
    visited = set()
    cur = node

    while cur not in visited:
        if cur in all_visited:
            return 0
        visited.add(cur)
        all_visited.add(cur)
        cur = favorite[cur]

    cycle_start = cur
    distance = find_distance(node, cycle_start, favorite)
    cycle_len = len(visited) - distance
    if cycle_len == 2:
        two_cycles[cycle_start] = 0
        two_cycles[favorite[cycle_start]] = 0
    return cycle_len


def find_distance(first, last, favorite):
    cur = first
    distance = 0
    while cur != last:
        cur = favorite[cur]
        distance += 1
    return distance


def dfs(start, graph, two_cycles):
    visited = set()
    cur = start
    nodes = [(cur, 0)]
    max_dist = 0
    while nodes:
        n, dist = nodes.pop()
        max_dist = max(dist, max_dist)
        for child in graph[n]:
            if child not in two_cycles:
                nodes.append((child, dist + 1))
    two_cycles[start] = max_dist


def build_graph(favorite):
    graph = collections.defaultdict(list)
    for i, fav in enumerate(favorite):
        graph[fav].append(i)
    return graph
