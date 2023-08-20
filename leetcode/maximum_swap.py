# 07:42 started reading
# 07:43 started thinking
# 07:47 started writing
# 07:55 started checking
# 07:57 checked, bugs: swap in str instead of a list, and typo when defining rest


class Solution:
    def maximumSwap(self, num: int) -> int:
        digits = list(str(num))
        for i, cur_digit in enumerate(digits):
            rest = digits[i + 1:]
            if rest:
                max_index, max_digit = max(enumerate(rest, start=i + 1), key=latest_indexes_first)
                if int(max_digit) > int(cur_digit):
                    swap(digits, i, max_index)
                    return int(''.join(digits))
        return num


def latest_indexes_first(index_and_value: (int, int)) -> (int, int):
    index, value = index_and_value
    return value, index


def swap(items, left, right):
    items[left], items[right] = items[right], items[left]