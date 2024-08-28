package leetcode

/*

20:12 started reading
20:16 started thinking
20:22 started writing
20:33 started checking
20:35 checked, no bugs, just couple of compilation errors, but solution is not optimal

consider each r,c, target is easy, we just keep counts

& column c is "good"

we find all rows having black pixel at c - this can be done in O(rows) time
each row is essentially a string,
compare each row to another row it's O(rows^2 * cols^2)
add it to dictionary and count number of items in a dictionary, it's O(rows^2 * cols)
*/

func findBlackPixel(picture [][]byte, target int) int {
	if len(picture) == 0 {
		return 0
	}

	numRows := len(picture)
	numColumns := len(picture[0])
	blackCountInRow := make([]int, numRows)
	blackCountInColumn := make([]int, numColumns)
	for r, row := range picture {
		for c, pixel := range row {
			if pixel == 'B' {
				blackCountInRow[r]++
				blackCountInColumn[c]++
			}
		}
	}

	goodColumns := buildGoodColumns(picture)

	count := 0
	for r, row := range picture {
		for c, pixel := range row {
			if pixel == 'B' && blackCountInRow[r] == target && blackCountInColumn[c] == target && goodColumns[c] {
				count++
			}
		}
	}
	return count
}

func buildGoodColumns(picture [][]byte) map[int]bool {
	goodColumns := map[int]bool{}
	numColumns := len(picture[0])
	for c := 0; c < numColumns; c++ {
		goodColumns[c] = isGoodColumn(picture, c)
	}
	return goodColumns
}

func isGoodColumn(picture [][]byte, c int) bool {
	rows := map[string]bool{}
	for _, row := range picture {
		if row[c] == 'B' {
			rows[string(row)] = true
		}
	}
	return len(rows) == 1
}
