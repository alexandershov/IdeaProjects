/*

21:22 started reading
21:23 started thinking
21:30 started writing
21:44 started checking
21:51 checked
21:53 TLE, >= instead >
21:54 wrong answer
22:21 forgot to update counts when adding current element
12:50 rewritten without counts


ideas:
1. sliding window with or, store counts
2. dp for each index, longest starting with index
    dp[0] - just extend till mismatch
    dp[n] - if overlaps with dp[n-1], extend from end

*/

func longestNiceSubarray(nums []int) int {
	if len(nums) == 0 {
		return 0
	}
	end := 0
	longest := 0
	bitMask := 0
	for i, _ := range nums {
		for end < len(nums) && (bitMask&nums[end]) == 0 {
			bitMask |= nums[end]
			end++
		}
		longest = max(longest, end-i)
		bitMask ^= nums[i]
	}
	return longest
}
