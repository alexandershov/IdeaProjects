package leetcode

/*
14:34 started reading
14:35 started thinking
14:39 started writing cubic algorithm
15:08 started checking
15:14 checked
15:31 typo in getDistance, and bunch of syntax errors, no algorithmic bugs

ideas:
* cubic algorithm where we fix three points and find the fourth one
*/

import (
	"fmt"
	"math"
)

type Point = []int

func minAreaFreeRect(points [][]int) float64 {
	minArea := float64(0)
	pointsCache := buildPointsCache(points)
	for i, pi := range points {
		for j, pj := range points {
			for k, pk := range points {
				if i == j || j == k || i == k {
					continue
				}
				if !isRectangle(pi, pj, pk) {
					continue
				}

				lastP := findSymmetric(pi, pj, pk)
				if !cacheContains(pointsCache, lastP) {
					continue
				}

				curArea := computeArea(pi, pj, pk)
				fmt.Printf("curArea = %v\n", curArea)
				if minArea == 0 || curArea < minArea {
					minArea = curArea
				}
			}
		}
	}
	return minArea
}

func buildPointsCache(points []Point) map[string]bool {
	cache := map[string]bool{}
	for _, p := range points {
		cache[getCacheKey(p)] = true
	}
	return cache
}

func getCacheKey(p Point) string {
	return fmt.Sprintf("%v_%v", getX(p), getY(p))
}

func getX(p Point) int {
	return p[0]
}

func getY(p Point) int {
	return p[1]
}

func cacheContains(cache map[string]bool, p Point) bool {
	key := getCacheKey(p)
	return cache[key]
}

func findSymmetric(lineFirst Point, lineSecond Point, target Point) Point {
	doubleMiddleX := getX(lineFirst) + getX(lineSecond)
	doubleMiddleY := getY(lineFirst) + getY(lineSecond)
	symmetricX := doubleMiddleX - getX(target)
	symmetricY := doubleMiddleY - getY(target)
	return Point{symmetricX, symmetricY}
}

func isRectangle(lineFirst, lineSecond, target Point) bool {
	firstX := getX(lineFirst) - getX(target)
	secondX := getX(lineSecond) - getX(target)
	firstY := getY(lineFirst) - getY(target)
	secondY := getY(lineSecond) - getY(target)
	scalarProduct := firstX*secondX + firstY*secondY
	return scalarProduct == 0
}

func computeArea(lineFirst Point, lineSecond Point, target Point) float64 {
	width := getDistance(target, lineFirst)
	height := getDistance(target, lineSecond)
	return width * height
}

func getDistance(a, b Point) float64 {
	dx := getX(b) - getX(a)
	dy := getY(b) - getY(a)
	return math.Sqrt(float64(dx*dx + dy*dy))
}
