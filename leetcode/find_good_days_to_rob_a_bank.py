# 10:01 started reading
# 10:04 started thinking
# 10:06 started writing
# 10:21 started checking
# 10:26 checked
# 10:28 wrong answer
# 10:32 misunderstood the problem statement
# 10:36 fixed after a couple of false starts


# ideas
# dynamic programming

# check, time = 0

class Solution:
    def goodDaysToRobBank(self, security: list[int], time: int) -> list[int]:
        before_counts = build_for_each_index(security)
        after_counts = build_for_each_index(security[::-1])[::-1]
        days = []
        for i, (before, after) in enumerate(zip(before_counts, after_counts)):
            if (before - 1) >= time and (after - 1) >= time:
                days.append(i)
        return days


def build_for_each_index(security: list[int]) -> list[int]:
    before_counts = [1]
    prev_value = security[0]

    for i in range(1, len(security)):
        prev_count = before_counts[i - 1]
        cur_value = security[i]
        if cur_value <= prev_value:
            count = prev_count + 1
        else:
            count = 1
        before_counts.append(count)
        prev_value = cur_value
    return before_counts


