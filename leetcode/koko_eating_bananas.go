package leetcode

/*
00:35 started reading
00:37 started thinking
00:40 started writing
00:50 started checking
00:52 checked, no bugs

ideas:
* binary search log(10^9) solve for each k 1000 * 9 * log(10)

*/

import (
	"slices"
)

func minEatingSpeed(piles []int, h int) int {
	a := 1
	b := slices.Max(piles) + 1
	// find min k, such that we can eat piles in h
	result := slices.Max(piles)
	for b-a >= 1 {
		k := (b + a) / 2
		if canEat(piles, h, k) {
			result = min(result, k)
			b = k
		} else {
			a = k + 1
		}
	}
	return result
}

func canEat(piles []int, h int, k int) bool {
	time := 0
	for _, bananas := range piles {
		extra := 0
		if bananas%k != 0 {
			extra = 1
		}
		time += bananas/k + extra
	}
	return time <= h
}
