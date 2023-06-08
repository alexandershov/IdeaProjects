# 09:34 started reading
# 09:35 started thinking
# 09:50 started writing O(m^2 * n)
# 09:58 started checking
# 10:00 checked, found a bug
# 10:02 continue, start over with brute force
# 10:06 implemented brute force, TLE as expected
# 15:58 continue with tries
# 16:30 figured out O(m * n) with two tries, started writing
# 16:45 started checking
# 16:49 checked
# 16:52 couple of typos
# 16:52 KeyError (bug in find_biggest_suffix_node)
# 16:56 NoneType AttributeError ()
# 17:00 wrong answer: approach is wrong, you can't compare counts of prefixes & suffixes, just forgot about it.
# 17:06 pause
# 10:00 continue, started thinking
# 10:29 started writing fast hash solution
# 10:31 pause, this is still O(m^2 * n)
# 12:50 continue with the sparse hash that'll give O(m * n)
# 12:57 started checking
# 13:00 checked
# 13:03 lot of small errors and TLE


# ideas:
# iterate over all strings in parallel and group somehow
# same prefix and same suffix
# trie

NUM_HASH_CHARS = 10


class PrefixAndSuffix:
    def __init__(self, string: str, i: int):
        self._string = string
        self._i = i

    def __eq__(self, other) -> bool:
        if not isinstance(other, PrefixAndSuffix):
            return False
        if self._i != other._i:
            return False
        for i, (ch, other_ch) in enumerate(zip(self._string, other._string)):
            if i == self._i:
                continue
            if ch != other_ch:
                return False
        return self._string[self._i] != other._string[other._i]

    def __hash__(self):
        i = self._i
        prefix_size = i
        suffix_size = len(self._string) - prefix_size - 1
        return hash((prefix_size, suffix_size, self._sparse_hash(0, i), self._sparse_hash(i + 1, len(self._string))))

    def _sparse_hash(self, begin: int, end: int) -> int:
        step = max(1, (end - begin) // NUM_HASH_CHARS)
        return hash(''.join(self._string[i] for i in range(begin, end, step)))


class Solution:
    def differByOne(self, dict: list[str]) -> bool:
        strings = dict
        pairs = set()
        for a_string in strings:
            for a_pair in iter_pairs(a_string):
                if a_pair in pairs:
                    return True
                pairs.add(a_pair)
        return False


def iter_pairs(string: str):
    for i in range(0, len(string)):
        yield PrefixAndSuffix(string, i)
