package leetcode

/*

20:44 started reading
20:45 started thinking
20:55 started writing
21:00 figured out how to use heap in go
21:11 started checking
21:12 checked
21:24 couple of golang bugs, also bug when candidate is not in map

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
	"container/heap"
	"math"
)

func maximumSubarraySum(nums []int, k int) int64 {
	prefixSum := int64(0)
	prefixSums := make([]int64, len(nums))
	heapByValue := map[int]*IntHeap{}
	for _, value := range nums {
		h := &IntHeap{}
		heap.Init(h)
		heapByValue[value] = h
	}
	result := int64(math.MinInt64)
	for i, value := range nums {
		prefixSums[i] = prefixSum
		prefixSum += int64(value)
		candidates := []int{value + k, value - k}
		for _, c := range candidates {
			heap, exists := heapByValue[c]
			if exists && heap.Len() > 0 {
				newResult := prefixSum - int64((*heap)[0])
				result = max(result, newResult)
			}
		}
		h := heapByValue[value]
		heap.Push(h, prefixSums[i])
	}
	if result == math.MinInt64 {
		return 0
	}
	return result
}

// An IntHeap is a min-heap of ints.
type IntHeap []int64

func (h IntHeap) Len() int           { return len(h) }
func (h IntHeap) Less(i, j int) bool { return h[i] < h[j] }
func (h IntHeap) Swap(i, j int)      { h[i], h[j] = h[j], h[i] }

func (h *IntHeap) Push(x any) {
	// Push and Pop use pointer receivers because they modify the slice's length,
	// not just its contents.
	*h = append(*h, x.(int64))
}

func (h *IntHeap) Pop() any {
	old := *h
	n := len(old)
	x := old[n-1]
	*h = old[0 : n-1]
	return x
}
