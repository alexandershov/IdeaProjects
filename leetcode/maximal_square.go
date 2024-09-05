package leetcode

/*

21:16 started reading
21:16 started thinking
21:32 started writing
22:01 started checking
22:07 checked
22:11 bunch of syntax/type errors
22:11 wrong answer, bad initialization of maxSize
22:13 wrong answer
22:21 bad calculation of worst
22:21 done


ideas:
* go from the bottom and the right
*
* if we have a function is_square(top_left, size), [true, true, true, false]
* [no, too large O]if we have a function count_ones(top_left, bottom_right)


(r, c) - as top left





*/

func maximalSquare(matrix [][]byte) int {
	if len(matrix) == 0 {
		return 0
	}

	onesToTheRight := makeOnesToTheRight(matrix)
	onesToTheBottom := makeOnesToTheBottom(matrix)

	numRows := len(matrix)
	numCols := len(matrix[0])

	maxSize := 0
	maxSizes := deepCopy(matrix)
	curR := numRows - 1
	curC := numCols - 1
	for curR >= 0 && curC >= 0 {
		for r := curR; r >= 0; r-- {
			curSize := getCurSize(matrix, maxSizes, onesToTheRight, onesToTheBottom, r, curC)
			maxSize = max(maxSize, curSize)
			maxSizes[r][curC] = curSize
		}
		for c := curC; c >= 0; c-- {
			curSize := getCurSize(matrix, maxSizes, onesToTheRight, onesToTheBottom, curR, c)
			maxSize = max(maxSize, curSize)
			maxSizes[curR][c] = curSize
		}
		curR -= 1
		curC -= 1
	}
	return maxSize * maxSize
}

func getCurSize(matrix [][]byte, maxSizes [][]int, onesToTheRight [][]int, onesToTheBottom [][]int, r, c int) int {
	numRows := len(matrix)
	numCols := len(matrix[0])
	if matrix[r][c] == '0' {
		return 0
	}
	if r == numRows-1 || c == numCols-1 {
		return 1
	}
	prev := maxSizes[r+1][c+1]
	worst := min(onesToTheRight[r][c], onesToTheBottom[r][c])
	if worst >= prev {
		return prev + 1
	}
	return worst + 1
}

func makeOnesToTheRight(matrix [][]byte) [][]int {
	numCols := len(matrix[0])
	result := zeroes(matrix)
	for r, _ := range matrix {
		numOnes := 0
		for c := numCols - 1; c >= 0; c-- {
			result[r][c] = numOnes
			cell := matrix[r][c]
			if cell == '1' {
				numOnes++
			} else {
				numOnes = 0
			}
		}
	}
	return result
}

func makeOnesToTheBottom(matrix [][]byte) [][]int {
	numRows := len(matrix)
	numCols := len(matrix[0])
	result := zeroes(matrix)
	for c := 0; c < numCols; c++ {
		numOnes := 0
		for r := numRows - 1; r >= 0; r-- {
			result[r][c] = numOnes
			cell := matrix[r][c]
			if cell == '1' {
				numOnes++
			} else {
				numOnes = 0
			}
		}
	}
	return result
}

func zeroes(matrix [][]byte) [][]int {
	result := [][]int{}
	for _, row := range matrix {
		result = append(result, make([]int, len(row)))
	}
	return result
}

func deepCopy(matrix [][]byte) [][]int {
	result := [][]int{}
	for r, row := range matrix {
		result = append(result, make([]int, len(row)))
		for c, cell := range row {
			if cell == '1' {
				result[r][c] = 1
			} else {
				result[r][c] = 0
			}
		}
	}
	return result
}
