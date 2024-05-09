package leetcode

import "fmt"

// 15:49 started reading
// 15:50 started thinking
// 15:53 thinking about solving for each pair
// 15:57 got O(n^2) * O(log(N^2))
// 15:59 thinking more
// 16:00 thinking about fixing top left and bottom right
// 16:00 started writing
// 16:13 started checking
// 16:17 checked

// Ideas
// solve for each pair - find
// group somehow by x/y

func πminAreaRect(points [][]int) int {
	area := 0
	pointExists := buildPointExists(points)
	for _, topLeft := range points {
		for _, bottomRight := range points {
			if !formRectangle(topLeft, bottomRight) {
				continue
			}
			topRight := []int{getX(bottomRight), getY(topLeft)}
			bottomLeft := []int{getX(topLeft), getY(bottomRight)}
			if pointExists[toString(topRight)] && pointExists[toString(bottomLeft)] {
				width := getX(topRight) - getX(topLeft)
				height := getY(topRight) - getY(bottomRight)
				curArea := width * height
				if area == 0 || curArea < area {
					area = curArea
				}
			}
		}
	}
	return area
}

func getX(point []int) int {
	return point[0]
}

func getY(point []int) int {
	return point[1]
}

func formRectangle(maybeTopLeft, maybeBottomRight []int) bool {
	return getX(maybeTopLeft) < getX(maybeBottomRight) && getY(maybeTopLeft) > getY(maybeBottomRight)
}

func toString(p []int) string {
	return fmt.Sprintf("%s_%s", getX(p), getY(p))
}

func buildPointExists(points [][]int) map[string]bool {
	result := map[string]bool{}
	for _, p := range points {
		result[toString(p)] = true
	}
	return result
}
