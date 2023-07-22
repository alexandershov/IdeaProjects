# 11:14 started reading
# 11:14 started thinking
# 11:19 started writing
# 11:24 started checking
# 11:27 checked, no bugs

# ideas:
# dp for each ending index

# observation: monotonic string is a recursive data structure

class Solution:
    def minFlipsMonoIncr(self, s: str) -> int:
        num_prev_ones = 0
        result = 0
        for i, bit in enumerate(s):
            if bit == '0':
                num_flips_cur_changed = result + 1
                num_flips_cur_not_changed = num_prev_ones
                result = min(num_flips_cur_changed, num_flips_cur_not_changed)
            elif bit == '1':
                num_prev_ones += 1
            else:
                raise ValueError(f'unexpected {bit=}, should be 0 or 1')
        return result
