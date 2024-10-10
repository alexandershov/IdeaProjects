package leetcode

/*
19:27 started reading
19:28 started thinking
19:37 started writing
19:44 started checking
19:46 checked
19:48 couple of golang bugs and wrong if condition with exit from cachedCanPartition

Left + Right
Find subset with the given sum

[3, 5, | 2, 6]
[3, 5, 10]

prerequisites of the array:
sum is even
Left = Right = Sum / 2
Avg = Sum / Count = Left / (2 * Count) = Right / (2 * Count)

is_possible([], 0) == True
is_possible(arr, k) = is_possible(arr[1:], k - 1)


Ideas:
* Dynamic programming
* Is it knapsack?
* Sorting

*/

type Cache = map[int]map[int]bool

func canPartition(nums []int) bool {
	sum := 0
	for _, value := range nums {
		sum += value
	}

	if sum%2 == 1 {
		return false
	}

	cache := Cache{}

	return cachedCanPartition(nums, 0, sum/2, cache)
}

func cachedCanPartition(nums []int, start int, goal int, cache Cache) bool {
	if start == len(nums) {
		return goal == 0
	}
	if _, startFound := cache[start]; !startFound {
		cache[start] = make(map[int]bool)
	}
	if value, isCached := cache[start][goal]; isCached {
		return value
	}
	result := cachedCanPartition(nums, start+1, goal, cache) || cachedCanPartition(nums, start+1, goal-nums[start], cache)
	cache[start][goal] = result
	return result
}
