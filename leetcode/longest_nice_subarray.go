package leetcode

/*

21:22 started reading
21:23 started thinking
21:30 started writing
21:44 started checking
21:51 checked
21:53 TLE, >= instead >
21:54 wrong answer
22:21 forgot to update counts when adding current element


ideas:
1. sliding window with or, store counts
2. dp for each index, longest starting with index
    dp[0] - just extend till mismatch
    dp[n] - if overlaps with dp[n-1], extend from end

*/

func longestNiceSubarray(nums []int) int {
	var counts = [64]int{}
	prevStart := -1
	prevEnd := 0
	longest := 0
	for i, _ := range nums {
		// pop previous
		if prevStart >= 0 {
			prevNum := nums[i-1]
			bit := 0
			for prevNum > 0 {
				if (prevNum & 1) == 1 {
					counts[bit] -= 1
				}
				prevNum = prevNum >> 1
				bit++
			}
		}
		bitMask := countsToBitMask(counts)
		prevEnd = max(i, prevEnd)
		for (prevEnd < len(nums)) && ((nums[prevEnd] & bitMask) == 0) {
			bitMask = bitMask | nums[prevEnd]
			v := nums[prevEnd]
			bit := 0
			for v > 0 {
				if (v & 1) == 1 {
					counts[bit] += 1
				}
				v = v >> 1
				bit++
			}
			prevEnd++
		}
		prevStart = i
		longest = max(longest, prevEnd-prevStart)
	}
	return longest
}

func countsToBitMask(counts [64]int) int {
	bitMask := 0
	cur := 1
	for _, c := range counts {
		if c > 0 {
			bitMask = bitMask | cur
		}
		cur = cur << 1
	}
	return bitMask
}
