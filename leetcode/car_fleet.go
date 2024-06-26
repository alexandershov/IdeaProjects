package leetcode

/*
20:15 started reading
20:19 started thinking
21:16 pause (for a week), wtf is this problem
21:47 continue
22:00 sliding window from reverse??
22:01 started writing
22:15 started checking
22:19 checked, couple of typos and wrong answer
22:26 bad floating point comparison


observations:
speed for each car can only decrease

algo:

ideas:
[nope]1. dp on [0; target]
[nope]2. simulation from the end
[nope]3. graphs
[nope]4.  dp on hour
[nope]5. calc for each car its speed
[nope]6. dp calc for each car its fleet size
[nope]7.  for each car: how many cars can catch up and what's the slowest of them?
[nope]8. find the slowest car, we always know its speed
[note]9. calculate number of fleets for each speed and sum them
[promising]10. find for each car the first car it'll catch up with, build a undirected graph out of it, find number of islands
  Now we just need for each car find the first car it'll catch up
  can we get away with finding _any_ car that our car will catch up with? No, we can be slowed down, so we need to consider first slow down
[nope]11. union find
[promising]12. sliding window from reverse

position, target, speed

a -> b -> c
we catch up only when speed is lower


*/

import (
	"sort"
)

type Entry struct {
	pos   int
	index int
}

func carFleet(target int, position []int, speed []int) int {
	// we need an array (position, index) sorted by position
	entries := []Entry{}
	for i, pos := range position {
		entries = append(entries, Entry{pos: pos, index: i})
	}
	sort.Slice(entries, func(i, j int) bool {
		return entries[i].pos < entries[j].pos
	})
	count := 0
	cur := len(entries) - 1
	for cur >= 0 {
		count += 1
		i := cur - 1

		for i >= 0 {
			curTime := getTime(target, speed[entries[cur].index], entries[cur].pos)
			prevTime := getTime(target, speed[entries[i].index], entries[i].pos)
			canCatchUp := prevTime <= curTime
			if !canCatchUp {
				break
			}
			i -= 1
		}
		cur = i
	}
	return count
}

func getTime(target int, speed int, position int) float64 {
	distance := target - position
	return float64(distance) / float64(speed)
}
