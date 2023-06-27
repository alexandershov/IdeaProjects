# 09:28 started reading
# 09:29 started thinking
# 09:39 started writing
# 09:44 started checking
# 09:50 checked
# 09:52 bugs: typo when inserting into dictionary and returned indexes instead of values

import heapq


class Solution:
    def kSmallestPairs(self, nums1: list[int], nums2: list[int], k: int) -> list[list[int]]:
        heap = [(nums1 + nums2, 0, 0)]
        pairs = {}  # (i1, i2) -> True
        while len(pairs) < k and heap:
            _, i1, i2 = heapq.heappop(heap)
            if (i1, i2) in pairs:
                continue
            pairs[(i1, i2)] = True

            if i1 < len(nums1) - 1:
                heapq.heappush(heap, make_move(nums1, nums2, i1 + 1, i2))
            if i2 < len(nums2) - 1:
                heapq.heappush(heap, make_move(nums1, nums2, i1, i2 + 1))
        return [[nums1[i1], nums2[i2]] for (i1, i2) in pairs]


def make_move(nums1, nums2, i1, i2):
    return (nums1[i1] + nums2[i2], i1, i2)
