# 11:42 started reading
# 11:45 started thinking
# 11:54 started writing sliding window
# 12:02 started checking
# 12:06 checked, got a couple of typos


# ideas: max(subarray) - min(subarray) <= limit
# dynamic programming for each index:
# for each subarray with the last element at i find the size + min + max
# sliding window

import sortedcontainers


class Solution:
    def longestSubarray(self, nums: list[int], limit: int) -> int:
        if not nums:
            return 0
        left = 0
        right = 0
        result = 1
        elements = sortedcontainers.SortedList([nums[0]])
        while right < len(nums) - 1:
            if can_extend_to(elements, nums, right + 1, limit):
                elements.add(nums[right + 1])
                right += 1
            else:
                drop_at(elements, nums, left)
                left += 1
            result = max(result, len(elements))
        return result


def can_extend_to(elements, nums, right, limit):
    if not elements:
        return True
    item = nums[right]
    new_min = min(elements[0], item)
    new_max = max(elements[-1], item)
    if abs(new_max - new_min) <= limit:
        return True
    return False


def drop_at(elements, nums, left):
    elements.remove(nums[left])
