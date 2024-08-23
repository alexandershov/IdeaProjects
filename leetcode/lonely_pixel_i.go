package leetcode

/*
07:01 started reading
07:02 started thinking
07:04 started writing
07:15 started checking
07:20 need to modify approach, bool doesn't hold enough information
07:25 modified, checked
07:26 couple of compilation errors, no bugs otherwise, but solution is not optimal space-wise
*/

func findLonelyPixel(picture [][]byte) int {
	if len(picture) == 0 {
		return 0
	}

	cache := makeEmptyCache(picture)
	numRows := len(picture)
	numColumns := len(picture[0])

	for r := 0; r < numRows; r++ {
		fillCache(cache, picture, r, 0, 0, 1)
		fillCache(cache, picture, r, numColumns-1, 0, -1)
	}

	for c := 0; c < numColumns; c++ {
		fillCache(cache, picture, 0, c, 1, 0)
		fillCache(cache, picture, numRows-1, c, -1, 0)
	}

	numLonelyPixels := 0
	for r := 0; r < numRows; r++ {
		for c := 0; c < numColumns; c++ {
			if cache[r][c] == 0 && picture[r][c] == 'B' {
				numLonelyPixels++
			}
		}
	}
	return numLonelyPixels
}

func makeEmptyCache(picture [][]byte) [][]int {
	cache := make([][]int, 0)
	for _, row := range picture {
		numColumns := len(row)
		cache = append(cache, make([]int, numColumns))
	}
	return cache
}

func fillCache(cache [][]int, picture [][]byte, r int, c int, deltaR int, deltaC int) {
	numRows := len(cache)
	numColumns := len(cache[0])
	curR := r
	curC := c
	numBlackBefore := 0
	for curR < numRows && curR >= 0 && curC < numColumns && curC >= 0 {
		cache[curR][curC] += numBlackBefore

		if picture[curR][curC] == 'B' {
			numBlackBefore++
		}

		curR += deltaR
		curC += deltaC
	}
}
