# 08:36 started reading
# 08:37 started thinking
# 08:48 started writing sortedcontainers solution
# 08:57 need to fix the finding first index that is smaller
# 09:00 monotonic stack
# 09:07 started checking
# 09:14 checked
# 09:15 bugs: forgot to remove change index calculation after got rid of offset,
# bugs: wrong calculation of index build_lt_index_after and forgot to reverse the result of build_lt_index_after


# ideas:
# [no]solve independently for each index i (find first < element to the right, that is less than heights[i])
# consider each bar a minimum height in a solution solve independently for each index i (find first < element to the right and to the left)
# maximize (right - left + 1) * min(left..right)


class Solution:
    def largestRectangleArea(self, heights: list[int]) -> int:
        lt_index_before = build_lt_index_before(heights)
        lt_index_after = build_lt_index_after(heights)
        result = 0
        for height, before_i, after_i in zip(heights, lt_index_before, lt_index_after):
            width = after_i - before_i - 1
            result = max(result, height * width)
        return result


def build_lt_index_before(heights):
    seen = []
    indexes = []
    for i, a_height in enumerate(heights):
        while seen and seen[-1][0] >= a_height:
            seen.pop()

        if seen:
            indexes.append(seen[-1][1])
        else:
            indexes.append(-1)
        seen.append((a_height, i))
    return indexes


def build_lt_index_after(heights):
    indexes = build_lt_index_before(reversed(heights))
    return reversed([len(indexes) - i - 1 for i in indexes])
