# 10:53 started reading
# 10:55 started thinking
# 11:13 trying to prove greedy
# 11:32 implemented greedy (with the bug in the loop condition),
# but don't understand why it'll give maximum split


# ideas:
# greedy
# answer is basically the same for odd/problem, but divided by 2
# dynamic programming

# observation: if it's odd then there's no solution
# [no]solution_even(2 * k) = map(2 * _, solution_odd(k))
# [no]solution_odd(2 * k + 1) =


class Solution:
    def maximumEvenSplit(self, finalSum: int) -> list[int]:
        result = []
        if finalSum % 2 == 1:
            return []

        cur_sum = 0
        smallest = 2
        while cur_sum != finalSum:
            next_smallest = smallest + 2
            left = finalSum - (cur_sum + smallest)
            if left >= next_smallest or left == 0:
                result.append(smallest)
                cur_sum += smallest
            smallest = next_smallest
        return result
