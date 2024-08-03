package leetcode

import "fmt"

/*

10:18 started reading
10:22 started thinking
10:25 started writing backtracking
10:38 started checking
10:41 checked
10:43 couple of compile errors
10:44 error: state should be a pointer
10:46 error: bad condition with center
10:53 error: forgot about 4 cases that have center
10:55 done

ideas:
* brute force is 10!
* backtracking

*/

type State struct {
	seen    map[int]bool
	centers map[string]int
	last    int
	count   int
}

func numberOfPatterns(m int, n int) int {
	seen := map[int]bool{}
	centers := map[string]int{
		"1_3": 2,
		"3_1": 2,
		"1_7": 4,
		"7_1": 4,
		"1_9": 5,
		"9_1": 5,
		"3_7": 5,
		"7_3": 5,
		"3_9": 6,
		"9_3": 6,
		"7_9": 8,
		"9_7": 8,
		"4_6": 5,
		"6_4": 5,
		"2_8": 5,
		"8_2": 5,
	}
	state := State{seen: seen, centers: centers, last: 0, count: 0}
	countPatterns(m, n, &state)
	return state.count
}

func countPatterns(m int, n int, state *State) {
	if len(state.seen) >= m && len(state.seen) <= n {
		state.count += 1
	}
	if len(state.seen) == n {
		return
	}
	for next := 1; next <= 9; next++ {
		if state.seen[next] {
			continue
		}
		key := fmt.Sprintf("%d_%d", state.last, next)
		center := state.centers[key]
		if center != 0 && !state.seen[center] {
			continue
		}
		state.seen[next] = true
		oldLast := state.last
		state.last = next
		countPatterns(m, n, state)
		delete(state.seen, next)
		state.last = oldLast
	}
}
