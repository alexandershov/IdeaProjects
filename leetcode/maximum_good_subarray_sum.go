package leetcode

/*

20:44 started reading
20:45 started thinking
20:55 started writing
21:00 figured out how to use heap in go
21:11 started checking
21:12 checked
21:24 couple of golang bugs, also bug when candidate is not in map
21:31 improved from O(n * log(n) to O(n), we don't need heap, just minimum

ideas:
* dp


dp
we know solution for nums[:i]
how to extend to nums[:i + 1]
nums[:i + 1] - we know prefix sum for this
we need to find j such that, nums[j] = nums[i] +/- k
vals: [indexes, prefix_sums_till], smallest prefix sum


O(n)
{
  value: [indexes]
}

nums[i] - nums[j] == k
or
nums[i] - nums[j] = -k


nums[j] = nums[i] - k
or
nums[j] = nums[i] + k

we know all candidate indexes

this is O(n^2)



*/

import (
	"math"
)

func maximumSubarraySum(nums []int, k int) int64 {
	prefixSum := int64(0)
	prefixSums := make([]int64, len(nums))
	minByValue := map[int]int64{}
	result := int64(math.MinInt64)
	for i, value := range nums {
		prefixSums[i] = prefixSum
		prefixSum += int64(value)
		candidates := []int{value + k, value - k}
		for _, c := range candidates {
			m, exists := minByValue[c]
			if exists {
				newResult := prefixSum - m
				result = max(result, newResult)
			}
		}
		if _, ok := minByValue[value]; !ok {
			minByValue[value] = prefixSums[i]
		}
		minByValue[value] = min(minByValue[value], prefixSums[i])
	}
	if result == math.MinInt64 {
		return 0
	}
	return result
}
