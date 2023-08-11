# 13:06 started reading
# 13:08 started thinking
# 13:14 started writing
# 13:31 started checking
# 13:38 checked
# 13:38 wrong answer, forgot about +1 when iterating over the range

# ideas:
# dynamic programming

# solve(m, start) = current player score
# m actions =>

class Solution:
    def stoneGameII(self, piles: list[int]) -> int:
        num_stones_start_at = build_num_stones_start_at(piles)
        return solve(num_stones_start_at, m=1, start=0)


def solve(num_stones_start_at: list[int], m: int, start: int, cache=None) -> int:
    if start == len(num_stones_start_at):
        return 0

    if cache is None:
        cache = {}

    key = (m, start)
    if key in cache:
        return cache[key]

    my_score = 0
    for num_taken in range(1, min(m * 2, len(num_stones_start_at)) + 1):
        next_m = max(m, num_taken)
        next_start = min(start + num_taken, len(num_stones_start_at))
        available_score = num_stones_start_at[start]
        opponent_score = solve(num_stones_start_at, m=next_m, start=next_start, cache=cache)
        my_score = max(my_score, available_score - opponent_score)

    cache[key] = my_score
    return my_score


def build_num_stones_start_at(piles: list[int]) -> list[int]:
    i = len(piles) - 1
    cumulative_sum = 0
    result = [0] * len(piles)
    while i >= 0:
        cur_pile = piles[i]
        cumulative_sum += cur_pile
        result[i] = cumulative_sum
        i -= 1
    return result
