# 11:39 started reading
# 11:40 started thinking
# 11:47 started writing
# 11:55 checked, no bugs


class Solution:
    def numDecodings(self, s: str) -> int:
        return find_num_decodings(s, start=0)


def find_num_decodings(s: str, start: int, cache=None) -> int:
    if cache is None:
        cache = {}

    if start in cache:
        return cache[start]
    if start == len(s):
        return 1

    result = 0

    if s[start] != '0':
        result += find_num_decodings(s, start=start + 1, cache=cache)
        if start + 1 < len(s):
            sub_str = s[start:start + 2]
            if 1 <= int(sub_str) <= 26:
                result += find_num_decodings(s, start=start + 2, cache=cache)

    cache[start] = result
    return result
