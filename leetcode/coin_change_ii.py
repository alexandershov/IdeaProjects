# 12:41 started reading
# 12:42 started thinking
# 12:44 started writing
# 12:47 started checking
# 12:50 checked
# 12:55 bug with duplicate combinations
# 12:56 start over
# 13:39 start writing not efficient version
# 13:45 submit, bug


# ideas:
# [no]dp on amount
# dp on amount+num_coins
# solve it mathematically

# f(coin_index, amount) = number of ways to solve for amount when coin_index is the last used coin


class Solution:
    def change(self, amount: int, coins: list[int]) -> int:
        prev = [1] + [0] * amount
        for a_coin in coins:
            cur = [0] * (amount + 1)
            for cur_amount in range(1, amount + 1):
                if cur_amount - a_coin >= 0:
                    # use coin once
                    cur[cur_amount] += prev[cur_amount - a_coin]
            for cur_amount in range(1, amount + 1):
                if cur_amount - a_coin >= 0:
                    # use coin again
                    cur[cur_amount] += cur[cur_amount - a_coin]
            prev = sum_lists(cur, prev)
        return prev[amount]


def sum_lists(left, right):
    return [x + y for x, y in zip(left, right)]
