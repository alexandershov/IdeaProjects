package leetcode

/*

10:48 started reading
10:49 started thinking
10:54 started writing
11:04 started checking
11:08 checked

length n gives us one n
length n gives us two n - 1
length n gives us three n - 2

(char, length): count

*/

import (
	"fmt"
	"strconv"
	"strings"
)

func maximumLength(s string) int {
	prev := byte(' ')
	groupLength := 0
	counts := map[string]int{}
	for i := 0; i < len(s)+1; i++ {
		cur := byte(' ')
		if i < len(s) {
			cur = s[i]
		}
		if cur != prev && prev != ' ' {
			key := fmt.Sprintf("%v_%d", prev, groupLength)
			counts[key]++
			if groupLength > 1 {
				key := fmt.Sprintf("%v_%d", prev, groupLength-1)
				counts[key] += 2
			}
			if groupLength > 2 {
				key := fmt.Sprintf("%v_%d", prev, groupLength-2)
				counts[key] += 3
			}
			groupLength = 0
		}
		groupLength++
		prev = cur
	}
	maxLength := -1
	for key, count := range counts {
		if count >= 3 {
			split := strings.Split(key, "_")
			length, err := strconv.Atoi(split[1])
			if err != nil {
				panic(split[1])
			}
			maxLength = max(maxLength, length)
		}
	}
	return maxLength
}
