# 10:53 started reading
# 10:55 started thinking
# 11:13 trying to prove greedy
# 11:32 implemented greedy (with the bug in the loop condition),


# ideas:
# [yes]greedy
# answer is basically the same for odd/problem, but divided by 2
# dynamic programming

# observation: if it's odd then there's no solution
# [no]solution_even(2 * k) = map(2 * _, solution_odd(k))
# [no]solution_odd(2 * k + 1) =


class Solution:
    def maximumEvenSplit(self, finalSum: int) -> list[int]:
        # here's why it works:
        # we find a sum of k consecutive evens such that
        # sum() >= finalSum
        # if sum() == finalSum, then we have an answer
        # if sum() > finalSum, then the answer length is < k
        # it can't be >= k, because we tried a minimal sum of first k evens
        # we then construct a solution of length k - 1
        # we remove the last item and increase second to last to correct amount
        if finalSum % 2 == 1:
            return []

        result = []

        cur_sum = 0
        item = 2
        while cur_sum < finalSum:
            cur_sum += item
            result.append(item)
            item += 2

        if cur_sum == finalSum:
            return result

        last = result.pop()
        extra = cur_sum - finalSum
        cur_sum -= last
        result[-1] += last - extra

        return result
