# 10:59 started reading
# 11:01 started thinking
# 11:09 got the idea with prev positive/negative
# 11:11 started writing
# 11:16 started checking
# 11:20 checked, no bugs, just forgot a matching paren

# ideas
# dynamic programming
# sliding window

class Solution:
    def getMaxLen(self, nums: list[int]) -> int:
        return max(max_positive for max_positive, max_negative in iter_maxes_at_indexes(nums))


def iter_maxes_at_indexes(nums):
    prev_max_positive = 0
    prev_max_negative = 0
    for a_num in nums:
        if a_num > 0:
            max_positive = prev_max_positive + 1
            max_negative = prev_max_negative + 1 if prev_max_negative else 0

        elif a_num < 0:
            max_positive = prev_max_negative + 1 if prev_max_negative else 0
            max_negative = prev_max_positive + 1
        else:
            max_positive = 0
            max_negative = 0
        yield max_positive, max_negative
        prev_max_positive, prev_max_negative = max_positive, max_negative
