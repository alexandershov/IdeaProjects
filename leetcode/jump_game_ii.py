# 10:23 started reading
# 10:24 started thinking
# 10:30 started trying heap solution
# 10:34 started writing
# 10:42 started checking
# 10:47 checked
# 10:49 wrong answer (incorrectly find the answer at the end)
# 10:51 fixed

# ideas
# heap - (num_jumps, i)


import heapq

class Solution:
    def jump(self, nums: list[int]) -> int:
        if len(nums) <= 1:
            return 0

        min_jumps = [(0, nums[0])]
        for cur_pos, a_num in enumerate(nums):
            if cur_pos == 0:
                continue

            while min_jumps and get_last_jump_pos(min_jumps[0]) < cur_pos:
                heapq.heappop(min_jumps)
            if min_jumps:
                head = min_jumps[0]
                num_jumps = head[0] + 1
                heapq.heappush(min_jumps, (num_jumps, cur_pos + a_num))
                if cur_pos == len(nums) - 1:
                    return num_jumps

        raise ValueError('impossible')


def get_last_jump_pos(item: tuple[int, int]) -> int:
    return item[1]