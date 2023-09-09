# 14:10 started reading
# 14:16 started thinking
# 14:47 started writing sort + dp
# 15:04 started checking
# 15:09 checked
# 15:11 TLE
# 14:56 started writing dijkstra
# 15:03 wrong signature of heapq, otherwise no bugs

"""
ideas
1. dynamic programming (probably no, there's no topological order between any two cells)
2. greedy (no)
3. sort + dp
"""
import collections
import heapq
import math


class Solution:
    def swimInWater(self, grid: list[list[int]]) -> int:
        values = collections.defaultdict(lambda: math.inf)
        start = (0, 0)
        target = (num_rows(grid) - 1, num_columns(grid) - 1)
        values[start] = at(grid, start)
        frontier = [(values[start], start)]
        while frontier:
            val, cell = heapq.heappop(frontier)
            values[cell] = min(values[cell], val)
            if cell == target:
                break
            for neighbour in iter_neighbours(cell, grid):
                new_value = max(at(grid, neighbour), val)
                if new_value < values[neighbour]:
                    values[neighbour] = new_value
                    heapq.heappush(frontier, (new_value, neighbour))
        return values[target]


def at(grid, cell):
    r, c = cell
    return grid[r][c]


class QuadraticSolution:
    def swimInWater(self, grid: list[list[int]]) -> int:
        if not grid:
            return 0
        answers = make_empty_answers(grid)
        values = sorted(((value, cell) for cell, value in iter_grid(grid)), reverse=True)
        target = (num_rows(grid) - 1, num_columns(grid) - 1)
        for a_value, (r, c) in values:
            visited, border = dfs((r, c), grid)
            if target in visited:
                answers[r][c] = a_value
            else:
                cur_answer = math.inf
                for (br, bc) in border:
                    cur_answer = min(cur_answer, answers[br][bc])
                answers[r][c] = cur_answer
        return answers[0][0]


def num_rows(grid):
    return len(grid)


def num_columns(grid):
    return len(grid[0])


def make_empty_answers(grid):
    rows = []
    for row in grid:
        cur_row = [math.inf] * len(row)
        rows.append(cur_row)
    return rows


def dfs(cell, grid):
    visited = set()
    r, c = cell
    max_value = grid[r][c]
    border = set()
    stack = [cell]
    while stack:
        node = stack.pop()
        visited.add(node)
        if node == (num_rows(grid) - 1, num_columns(grid) - 1):
            break
        for nr, nc in iter_neighbours(node, grid):
            if grid[nr][nc] <= max_value:
                if (nr, nc) not in visited:
                    stack.append((nr, nc))
            else:
                border.add((nr, nc))
    return visited, border


def iter_grid(grid):
    for r, row in enumerate(grid):
        for c, value in enumerate(row):
            yield (r, c), value


def iter_neighbours(cell, grid):
    r, c = cell
    if r - 1 >= 0:
        yield (r - 1, c)
    if r + 1 < num_rows(grid):
        yield (r + 1, c)
    if c - 1 >= 0:
        yield (r, c - 1)
    if c + 1 < num_columns(grid):
        yield (r, c + 1)
