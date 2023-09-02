# 11:47 started reading
# 11:48 started thinking
# 11:53 started writing
# 11:58 started checking
# 12:01 checked, no bugs

import math


class Solution:
    def minExtraChar(self, s: str, dictionary: list[str]) -> int:
        cache = [len(s)] * (len(s) + 1)
        cache[-1] = 0
        for i in reversed(range(len(s))):
            cache[i] = min(cache[i], 1 + cache[i + 1])
            for a_word in dictionary:
                if s.startswith(a_word, i):
                    cache[i] = min(cache[i], cache[i + len(a_word)])
        return cache[0]


def rec_solve(s: str, words: set[str], start: int, cache=None):
    if cache is None:
        cache = [math.inf] * len(s)
    if start == len(s):
        return 0
    if cache[start] != math.inf:
        return cache[start]
    num_chars = 1 + rec_solve(s, words, start + 1, cache)
    for a_word in words:
        if s.startswith(a_word, start):
            num_chars = min(num_chars, rec_solve(s, words, start + len(a_word), cache))
            cache[start] = num_chars
    return num_chars
