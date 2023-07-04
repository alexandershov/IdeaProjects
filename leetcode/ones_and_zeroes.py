# 14:51 started reading
# 14:52 started thinking
# 15:00 started writing
# 15:04 wrong approach, started thinking again
# 15:24 started writing 2d dynamic programming
# 15:34 started checking
# 15:39 checked
# 15:43 wrong assert set(counts) == {'0', '1'},
#  because counts can contain only ones (or only zeroes)

# ideas
# dynamic programming with some restriction on a solution
# ndimensional dynamic programming

import collections


class Solution:
    def findMaxForm(self, strs: list[str], m: int, n: int) -> int:
        max_sizes = init_max_sizes(m, n)  # (num_ones, num_zeroes) -> max_size
        for i, a_str in enumerate(strs):
            cur_num_ones, cur_num_zeroes = count_ones_and_zeroes(a_str)
            new_max_sizes = max_sizes.copy()
            for num_ones in range(0, n + 1):
                for num_zeroes in range(0, m + 1):
                    goal_num_ones = num_ones - cur_num_ones
                    goal_num_zeroes = num_zeroes - cur_num_zeroes
                    if goal_num_ones >= 0 and goal_num_zeroes >= 0:
                        key = (num_ones, num_zeroes)
                        goal_key = (goal_num_ones, goal_num_zeroes)
                        new_max_sizes[key] = max(new_max_sizes[key], max_sizes[goal_key] + 1)
            max_sizes = new_max_sizes
        return max(max_sizes.values())


def init_max_sizes(m: int, n: int) -> dict[(int, int), int]:
    max_sizes = {}
    for num_ones in range(0, n + 1):
        for num_zeroes in range(0, m + 1):
            max_sizes[(num_ones, num_zeroes)] = 0
    return max_sizes


def count_ones_and_zeroes(a_str: str) -> (int, int):
    counts = collections.Counter(a_str)
    assert set(counts).issubset({'0', '1'})
    return counts['1'], counts['0']
