package leetcode

// 22:28 started reading
// 22:29 started thinking
// 22:31 started writing
// 22:47 started checking
// 22:53 checked, no bugs, just a bunch of golang type and declaration errors

type NodeSet = map[int]bool
type Graph = map[int]NodeSet

func countPairs(n int, edges [][]int) int64 {
	visited := NodeSet{}
	graph := buildGraph(n, edges)
	counts := []int{}
	for i := 0; i < n; i++ {
		if !visited[i] {
			countBefore := len(visited)
			bfs(i, graph, visited)
			countAfter := len(visited)
			curCount := countAfter - countBefore
			counts = append(counts, curCount)
		}
	}
	return countPairsFromCounts(counts)
}

func buildGraph(n int, edges [][]int) Graph {
	graph := Graph{}

	for i := 0; i < n; i++ {
		graph[i] = NodeSet{}
	}
	for _, edge := range edges {
		x, y := edge[0], edge[1]
		graph[x][y] = true
		graph[y][x] = true
	}
	return graph
}

func bfs(node int, graph Graph, visited NodeSet) {
	frontier := []int{node}
	visited[node] = true
	for len(frontier) > 0 {
		cur := frontier[0]
		frontier = frontier[1:]
		for neighbor, _ := range graph[cur] {
			if !visited[neighbor] {
				frontier = append(frontier, neighbor)
				visited[neighbor] = true
			}
		}
	}
}

func countPairsFromCounts(counts []int) int64 {
	total := int64(0)
	for _, c := range counts {
		total += int64(c)
	}
	numDuplicatePairs := int64(0)
	for _, c := range counts {
		numOther := total - int64(c)
		numDuplicatePairs += int64(c) * numOther
	}
	return numDuplicatePairs / 2
}
