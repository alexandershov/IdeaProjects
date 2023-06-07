# 17:40 started reading
# 17:42 started thinking
# 17:52 got num_rows * num_cols * num_cols with dynamic programming
# 18:10 run out of the ideas, pause
# 11:46 continue, start writing num_rows * num_cols * num_cols
# 11:53 started checking
# 11:54 checked, TLE as expected
# 12:55 continue thinking
# 13:23 got idea of double dynamic programming
# 13:26 started writing
# 13:38 started checking
# 13:45 checked, a couple of typos and no bugs

# ideas:
# dynamic programming
# recursion
# backtracking search with some bound checking
# greedy - probably doesn't work

from typing import List


class Solution:
    def maxPoints(self, points: List[List[int]]) -> int:
        prev_row = points[0]
        for i in range(1, len(points)):
            costs = points[i]
            max_before, max_after = calc_running_maxes(prev_row)
            row = [0] * len(costs)
            for k, a_cost in enumerate(costs):
                row[k] = max(max_before[k] - k, max_after[k] + k, prev_row[k]) + a_cost
            prev_row = row
        return max(prev_row)


def calc_running_maxes(row: list[int]) -> tuple[list[int], list[int]]:
    return calc_maxes_before(row), calc_maxes_after(row)


def calc_maxes_before(row):
    maxes_before = [0] * len(row)
    running_max = float('-inf')
    for i, item in enumerate(row):
        maxes_before[i] = running_max
        running_max = max(running_max, item + i)
    return maxes_before


def calc_maxes_after(row):
    maxes_after = [0] * len(row)
    running_max = float('-inf')
    i = len(row) - 1
    while i >= 0:
        item = row[i]
        maxes_after[i] = running_max
        running_max = max(running_max, item - i)
        i -= 1
    return maxes_after
