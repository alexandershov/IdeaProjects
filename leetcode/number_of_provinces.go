package leetcode

/*

21:32 started reading
21:33 started thinking
21:34 started writing
21:40 started checking
21:42 checked, type error in isConnected
*/

func findCircleNum(isConnected [][]int) int {
	numProvinces := 0
	visited := map[int]bool{}
	for i := range isConnected {
		if visited[i] {
			continue
		}
		dfs(i, visited, isConnected)
		numProvinces += 1
	}
	return numProvinces
}

func dfs(i int, visited map[int]bool, isConnected [][]int) {
	if visited[i] {
		return
	}
	visited[i] = true
	for c, curIsConnected := range isConnected[i] {
		if curIsConnected == 1 {
			dfs(c, visited, isConnected)
		}
	}
}
