# Solving: https://leetcode.com/problems/longest-substring-with-at-most-two-distinct-characters/

# Sliding window is DP in disguise

# This is a classic DP solution
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        if not s:
            return 0

        # (longest length, counts) ending at index
        dp = [(1, {ch: 1}) for ch in s]
        i = 1
        result = 1

        while i < len(dp):
            prev_len, prev_counts = dp[i - 1]
            ch = s[i]
            k = i - prev_len

            while not ((ch in prev_counts) or len(prev_counts) <= 1):
                pop(prev_counts, s[k])
                k += 1
                prev_len -= 1

            cur_counts = prev_counts
            cur_counts.setdefault(ch, 0)
            cur_counts[ch] += 1
            cur_len = prev_len + 1
            result = max(result, cur_len)
            dp[i] = (cur_len, cur_counts)
            i += 1
        return result


# We actually only need the previous state, so we don't need the dp array
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        if not s:
            return 0

        # (longest length, counts) ending at index
        prev_len, prev_counts = 0, {}
        result = 1

        for i, ch in enumerate(s):
            ch = s[i]
            k = i - prev_len

            while not ((ch in prev_counts) or len(prev_counts) <= 1):
                pop(prev_counts, s[k])
                k += 1
                prev_len -= 1

            cur_counts = prev_counts
            cur_counts.setdefault(ch, 0)
            cur_counts[ch] += 1
            cur_len = prev_len + 1
            prev_len = cur_len
            prev_counts = cur_counts
            result = max(result, cur_len)
            i += 1
        return result


# Now we can rename stuff, so it's like a sliding window
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        if not s:
            return 0

        # (longest length, counts) ending at index
        prev_len, counts = 0, {}
        result = 1

        for i, ch in enumerate(s):
            ch = s[i]
            k = i - prev_len

            while not ((ch in counts) or len(counts) <= 1):
                pop(counts, s[k])
                k += 1
                prev_len -= 1

            counts.setdefault(ch, 0)
            counts[ch] += 1
            cur_len = prev_len + 1
            prev_len = cur_len
            result = max(result, cur_len)
            i += 1
        return result


# Now we can rename stuff, so it's like a sliding window
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        # (longest length, counts) ending at index
        prev_len, counts = 0, {}
        result = 0

        for i, ch in enumerate(s):
            ch = s[i]
            k = i - prev_len

            while not can_extend(counts, ch):
                pop(counts, s[k])
                k += 1
                prev_len -= 1

            counts.setdefault(ch, 0)
            counts[ch] += 1
            cur_len = prev_len + 1
            prev_len = cur_len
            result = max(result, cur_len)
            i += 1
        return result


# now we can introduce left and right instead of prev_len
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        # (longest length, counts) ending at index
        counts = {}
        left = 0
        right = 0
        result = 0

        while right < len(s):
            while right < len(s) and can_extend(counts, s[right]):
                counts.setdefault(s[right], 0)
                counts[s[right]] += 1
                right += 1
            result = max(result, right - left)
            while right < len(s) and not can_extend(counts, s[right]):
                pop(counts, s[left])
                left += 1
        return result


# we can still keep things close to DP, trick is to always apply right, and then compensate at left
class Solution:
    def lengthOfLongestSubstringTwoDistinct(self, s: str) -> int:
        # (longest length, counts) ending at index
        counts = {}
        left = 0
        result = 0

        for right, ch in enumerate(s):
            counts.setdefault(ch, 0)
            counts[ch] += 1
            while len(counts) > 2:
                pop(counts, s[left])
                left += 1
            result = max(result, right - left + 1)
        return result


def can_extend(counts, ch):
    return ch in counts or len(counts) <= 1


def pop(counts, char):
    counts[char] -= 1
    if counts[char] == 0:
        del counts[char]
