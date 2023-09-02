# 11:47 started reading
# 11:48 started thinking
# 11:53 started writing
# 11:58 started checking
# 12:01 checked, no bugs

import math

class Solution:
    def minExtraChar(self, s: str, dictionary: list[str]) -> int:
        return solve(s, set(dictionary), 0)


def solve(s: str, words: set[str], start: int, cache=None):
    if cache is None:
        cache = [math.inf] * len(s)
    if start == len(s):
        return 0
    if cache[start] != math.inf:
        return cache[start]
    num_chars = 1 + solve(s, words, start + 1, cache)
    for a_word in words:
        if s.startswith(a_word, start):
            num_chars = min(num_chars, solve(s, words, start + len(a_word), cache))
            cache[start] = num_chars
    return num_chars

