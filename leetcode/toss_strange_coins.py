# 17:53 started reading
# 17:54 started thinking
# 18:01 checking that formula works
# 18:03 started writing
# 18:15 started checking
# 18:17 checked

# ideas:
# some prob theory formula
# solve f(i + 1) using f(1), f(2), ... f(i)
#    f(i + 1, target) = f(i, target) * !p(i + 1) + f(i, target - 1) * p(i + 1) if target > 0
#   product(1 - p(i)) if target == 0
#
# simulation

from typing import List


class Solution:
    def probabilityOfHeads(self, prob: List[float], target: int) -> float:
        cache = {}  # (last_index, target) -> probabillity
        zero_heads_prob = 1
        for i, a_prob in enumerate(prob):
            zero_heads_prob *= 1 - a_prob
            cache[(i, 0)] = zero_heads_prob
        return calc_prob(prob, len(prob) - 1, target, cache)


def calc_prob(prob, i, target, cache):
    key = (i, target)

    if key in cache:
        return cache[key]

    if i == 0:
        if target == 1:
            result = prob[i]
        elif target == 0:
            result = 1 - prob[i]
        else:
            result = 0
    else:
        assert target > 0
        result = calc_prob(prob, i - 1, target, cache) * (1 - prob[i]) + calc_prob(prob, i - 1, target - 1, cache) * \
                 prob[i]
        cache[key] = result
    return result
