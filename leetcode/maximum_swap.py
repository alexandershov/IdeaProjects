# 07:42 started reading
# 07:43 started thinking
# 07:47 started writing
# 07:55 started checking
# 07:57 checked, bugs: swap in str instead of a list, and typo when defining rest
# 12:50 improved algo to O(b * log(b)) where b = log(num)

import heapq

MaxHeap = list


class Solution:
    def maximumSwap(self, num: int) -> int:
        digits = [int(a_digit) for a_digit in str(num)]
        rest = build_rest(digits)
        for i, cur_digit in enumerate(digits):
            while is_outdated(rest, i):
                pop_from(rest)

            if rest and get_value(rest[0]) > cur_digit:
                swap(digits, i, get_index(rest[0]))
                return int(''.join(map(str, digits)))
        return num


def build_rest(digits: list[int]) -> MaxHeap:
    rest = []
    for i, cur_digit in enumerate(digits):
        heapq.heappush(rest, (-cur_digit, -i))
    return rest


def pop_from(rest):
    heapq.heappop(rest)


def is_outdated(rest: MaxHeap, i: int) -> bool:
    if not rest:
        return False
    return get_index(rest[0]) <= i


def get_index(item) -> int:
    return -item[1]


def get_value(item) -> int:
    return -item[0]


def swap(items, left, right):
    items[left], items[right] = items[right], items[left]
