# 15:08 started reading
# 15:10 started thinking
# 15:16 started writing
# 15:26 started checking
# 15:29 checked, no bugs

# ideas
# two heaps (cost, i)

import heapq
import math


class Solution:
    def totalCost(self, costs: list[int], k: int, candidates: int) -> int:
        first = []
        second = []
        total_cost = 0

        first_end = 0
        for i in range(candidates):
            a_cost = costs[i]
            heapq.heappush(first, (a_cost, i))
            first_end = i + 1

        second_start = max(first_end, len(costs) - candidates)
        for i in range(second_start, len(costs)):
            a_cost = costs[i]
            heapq.heappush(second, (a_cost, i))

        for i in range(k):
            if get_value(first) < get_value(second):
                cost, _ = heapq.heappop(first)
                total_cost += cost
                if first_end < second_start:
                    heapq.heappush(first, (costs[first_end], first_end))
                    first_end += 1
            else:
                cost, _ = heapq.heappop(second)
                total_cost += cost
                if second_start > first_end:
                    second_start -= 1
                    heapq.heappush(second, (costs[second_start], second_start))
        return total_cost


def get_value(heap):
    if not heap:
        return (math.inf, math.inf)
    return heap[0]
