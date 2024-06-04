package leetcode

/*
19:35 started reading
19:37 started thinking
19:42 started writing
19:54 started checking
20:00 checked
20:02 no bugs, bunch of syntax errors and forgotten return

curDirectory
if it's a file, then just maximize
if it's a directory, with the same number of tabs, we grow currentDir
if it's a directory, with the lower number of tabs, we shrink currentDir
a
  b
    d
 x (level = 1, curLength = 3)
*/

import (
	"strings"
)

func lengthLongestPath(input string) int {
	curDirSegments := []string{}
	curDirLength := 0
	result := 0
	for _, line := range splitIntoLines(input) {
		level := computeLevel(line)
		for level < len(curDirSegments) {
			lastSegment := curDirSegments[len(curDirSegments)-1]
			curDirLength -= len(lastSegment)
			curDirSegments = curDirSegments[:len(curDirSegments)-1]
		}
		if level == len(curDirSegments) {
			if isFile(line) {
				fullDirLength := curDirLength + len(curDirSegments)
				curPathLength := fullDirLength + len(line[level:])
				result = max(result, curPathLength)
			} else {
				curDirSegments = append(curDirSegments, line[level:])
				curDirLength += len(line[level:])
			}
		} else {
			panic("level > len(curDirSegments")
		}

	}
	return result
}

func splitIntoLines(input string) []string {
	return strings.Split(input, "\n")
}

func computeLevel(line string) int {
	level := 0
	for _, char := range line {
		if char != '\t' {
			break
		}
		level += 1
	}
	return level
}

func isFile(line string) bool {
	return strings.Contains(line, ".")
}
