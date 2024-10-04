package leetcode

/*
03:07 started reading
03:09 started thinking
03:21 started writing
03:28 started checking
03:30 what if x == 1
03:36 checked, just couple of typos

we have count[x]
for k := powers of 2
isSolution(x, k) =
k == 1, true
k == 2, x^2 exists, extra x exists, isSolution(x, k - 1)
k == 4, x^4 exists, isSolution(x, k - 1), extra x^2 exists
k == 8, x^8 exists, isSolution(x, k - 1), extra x^4 exists

x, k = 1
x, x^2, x, k == 2, len = 3
x, x^2, x^4, x^2, x, k == 4, len = 5
x, x^2, x^4, x^8, x^4, x^2, x k == 8, len = 7
x, x^2, x^4, x^8, x^16, x^8, x^4, x^2, x, len = 9

*/

func maximumLength(nums []int) int {
	counts := map[int]int{}
	for _, aNum := range nums {
		counts[aNum]++
	}

	maxLength := max(floorToOdd(counts[0]), floorToOdd(counts[1]))

	for x := range counts {
		if x == 1 || x == 0 {
			continue
		}
		prev := 0
		xPowK := x
		length := 1
		for counts[xPowK] > 0 {
			if xPowK != x && counts[prev] <= 1 {
				break
			}
			maxLength = max(maxLength, length)
			prev = xPowK
			xPowK = xPowK * xPowK
			length += 2
		}
	}
	return maxLength
}

func floorToOdd(x int) int {
	if x%2 == 1 {
		return x
	}
	if x == 0 {
		return 0
	}
	return x - 1
}
