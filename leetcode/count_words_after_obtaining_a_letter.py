# 07:31 started reading
# 07:35 started thinking
# 07:38 got the O(n*alphabet^2) solution
# 07:40 started writing
# 07:45 started checking
# 07:48 checked, no bugs

# cba -> abc

from typing import Iterable


class Solution:
    def wordCount(self, startWords: list[str], targetWords: list[str]) -> int:
        start_signatures = {make_signature(a_word) for a_word in startWords}
        count = 0
        for target in targetWords:
            if any((start in start_signatures) for start in iter_starts(target)):
                count += 1
        return count


def make_signature(word: str) -> str:
    return ''.join(sorted(word))


def iter_starts(target: str) -> Iterable[str]:
    signature = make_signature(target)
    for i in range(len(signature)):
        yield signature[:i] + signature[i + 1:]
