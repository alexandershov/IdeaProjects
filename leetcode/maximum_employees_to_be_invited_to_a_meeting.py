# 10:37 started reading
# 10:38 started thinking
# 11:28 started writing
# 11:40 it's actually quadratic algorithm in the worse case
# 11:41 trying to submit it
# 11:44 forgot to change visited in find_invitations
# 11:50 wrong answer, current idea is DSU and check the cycle lengths, handle cycle.len == 2 separately
# 13:19 continue
# 13:41 wrong approach, solution can be constructed from disconnected components
# 14:11 still wrong approach, we can construct solutions in a weird way
# 14:15 thinking about completely different approach

# ideas:
# represent everything as a graph
# dfs/bfs
# number of free spots for each employee
# sort by in_degrees
# figure out one person to include and then just construct the solution
# find cycles with len > 2 and handle cycles with len == 2 separately
# find parts of graph, start with the start of each part


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
        if not starting_nodes:
            return n
        result = 0
        two_cycles = {}
        for start in starting_nodes:
            result = max(result, find_invitations(start, favorite, two_cycles))

        two_cycle_nodes = set()
        for node in two_cycles:
            two_cycle_nodes.add(node)
            two_cycle_nodes.add(favorite[node])
        num_two_cycles, rem = divmod(len(two_cycle_nodes), 2)
        assert rem == 0
        for node, path_len in two_cycles.items():
            two_cycle_result = two_cycles.get(favorite[node], 0) + path_len
            result = max(result, two_cycle_result + num_two_cycles * 2)
        return result


def build_in_degrees(favorite):
    in_degrees = dict.fromkeys(range(len(favorite)), 0)
    for fav in favorite:
        in_degrees[fav] += 1
    return in_degrees


def find_invitations(node, favorite, two_cycles):
    visited = set()
    cur = node

    while cur not in visited:
        visited.add(cur)
        cur = favorite[cur]

    cycle_start = cur
    distance = find_distance(node, cycle_start, favorite)
    cycle_len = len(visited) - distance
    if cycle_len == 2:
        two_cycles[cycle_start] = max(len(visited) - 2, two_cycles.get(cycle_start, 0))
        return 0
    return cycle_len


def find_distance(first, last, favorite):
    cur = first
    distance = 0
    while cur != last:
        cur = favorite[cur]
        distance += 1
    return distance
