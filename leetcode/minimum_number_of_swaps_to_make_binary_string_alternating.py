# 09:58 started reading
# 09:59 started thinking
# 10:09 started writing
# 10:16 started checking
# 10:19 checked, no bugs, just wrong variable names


# ideas:
# try first 1 and first 0
# greedy
# dynamic programming

class Solution:
    def minSwaps(self, s: str) -> int:
        result = min(num_swaps_with_first(s, first_char='0'), num_swaps_with_first(s, first_char='1'))
        if result == float('inf'):
            return -1
        return result


def num_swaps_with_first(s: str, first_char: str):
    num_misplaced_first = 0
    num_misplaced_second = 0
    for i in range(0, len(s), 2):
        if s[i] != first_char:
            num_misplaced_first += 1
        if i + 1 < len(s) and s[i + 1] == first_char:
            num_misplaced_second += 1
    if num_misplaced_first != num_misplaced_second:
        return float('inf')
    return num_misplaced_first
