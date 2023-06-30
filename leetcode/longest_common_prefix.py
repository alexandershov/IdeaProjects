# 12:34 started reading
# 12:35 started thinking
# 12:36 started writing
# 12:39 started checking
# 12:42 checked
# 12:47 bug: break from inner loop instead of outer loop

class Solution:
    def longestCommonPrefix(self, strs: list[str]) -> str:
        prefix = []
        i = 0

        while True:
            char = None
            for a_string in strs:
                if i >= len(a_string):
                    return ''.join(prefix)
                if char is None:
                    char = a_string[i]
                if a_string[i] != char:
                    return ''.join(prefix)
            prefix.append(char)
            i += 1
