# 10:37 started reading
# 10:38 started thinking
# 11:28 started writing
# 11:40 it's actually quadratic algorithm in the worse case
# 11:41 trying to submit it
# 11:44 forgot to change visited in find_invitations
# 11:50 wrong answer, current idea is DSU and check the cycle lengths, handle cycle.len == 2 separately

# ideas:
# represent everything as a graph
# dfs/bfs
# number of free spots for each employee
# sort by in_degrees
# figure out one person to include and then just construct the solution
# find cycles with len > 2 and handle cycles with len == 2 separately
# find parts of graph, start with the start of each part


class Solution:
    def maximumInvitations(self, favorite: list[int]) -> int:
        n = len(favorite)
        in_degrees = build_in_degrees(favorite)
        starting_nodes = [node for node, in_deg in in_degrees.items() if in_deg == 0]
        if not starting_nodes:
            return n
        result = 0
        for start in starting_nodes:
            result = max(result, find_invitations(start, favorite))
        return result


def build_in_degrees(favorite):
    in_degrees = dict.fromkeys(range(favorite), 0)
    for fav in favorite:
        in_degrees[fav] += 1
    return in_degrees


def find_invitations(node, favorite):
    visited = set()
    i = 0
    cur = node

    while cur not in visited:
        cur = favorite[cur]

    cycle_start = cur
    distance = find_distance(node, cycle_start, favorite)
    cycle_len = len(visited) - distance
    if cycle_len == 2:
        return len(visited)
    return cycle_len


def find_distance(first, last, favorite):
    cur = first
    distance = 0
    while cur != last:
        cur = favorite[cur]
        distance += 1
    return distance
