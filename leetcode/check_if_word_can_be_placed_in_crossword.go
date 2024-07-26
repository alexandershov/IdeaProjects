package leetcode

/*

13:20 started reading
13:21 started thinking
13:36 this is isomorphic to find substring in linear time with globs
13:39 reinventing KMP
13:40 pause
12:24 continue
12:32 can we just use regex and not reinvent KMP?
12:32 writing regex solution
12:43 hmm, haystack is regex, but string is static, this is like reverse regex match
12:49 back to KMP
13:04 pause
22:47 continue, we can't just modify KMP, because we also depend on wildcards during match
22:50 exploring dynamic programming
22:51 it's reverse glob matching, we have subwords, which are globs
22:52 it's elementary, because we only need to do the whole submatch, it's not a substring problem, just glob matching
22:53 start writing
23:04 started checking
23:06 checked
23:09 couple of type errors
23:09 TLE
23:17 looks like bytes.Split is not linear, made it without split
23:17 done

ideas:
* dynamic programming
* we need to solve only for one row & one direction linearly, the rest cases are isomorphic
  we can split into blocks, this is just glob substring matching in linear time
* KMP modification

implementation:
let's say we're search for ababc in abababc
let's say we have magical mapping (indexOfMismatchInPattern) -> offsetOfNewMatch

we've found mismatch at some position
now we need to determine at which position in the pattern we are.

if we mismatch on a first index in pattern, then we need to starting matching at textIndex + 1 and patternIndex = 0
If we mismatch on a second index in pattern,


finalText = abababc
                 ababc

pattern  = ababc
text       = 01234



we're mapping (textIndexDelta, newPatternIndex) to each index in pattern
0 -> (1, 0)
1 -> (1, 0)
2 -> (2, 0)
3 -> (2, 1)
4 -> (2, 2)


aababc
ababc
[1, ]
abababc

reverse regexps:
' ' is [a-z]
we can leave the rest of the characters as is



can_be_placed(s) = previous_characters, boolean

can_be_placed(s)
  if not can_be_placed(s[1:])
    false
  result = s[0] in previous_characters

can_be_placed(s) = can_be_placed(s[1:])

*/

func placeWordInCrossword(board [][]byte, word string) bool {
	numRows := len(board)
	numColumns := len(board[0])
	for ri := 0; ri < numRows; ri++ {
		row := getRow(board, ri)
		if canPlace(row, word) || canPlace(reverse(row), word) {
			return true
		}
	}
	for ci := 0; ci < numColumns; ci++ {
		column := getColumn(board, ci)
		if canPlace(column, word) || canPlace(reverse(column), word) {
			return true
		}
	}
	return false
}

func getRow(board [][]byte, ri int) []byte {
	return board[ri]
}

func getColumn(board [][]byte, ci int) []byte {
	result := []byte{}
	for _, row := range board {
		result = append(result, row[ci])
	}
	return result
}

func canPlace(text []byte, w string) bool {
	word := []byte{}
	for _, c := range w {
		word = append(word, byte(c))
	}
	start := 0
	for start < len(text) {
		end := start
		for end < len(text) && text[end] != byte('#') {
			end++
		}
		if match(text, word, start, end) {
			return true
		}
		for end < len(text) && text[end] == byte('#') {
			end++
		}
		start = end
	}
	return false
}

func match(text []byte, word []byte, start, end int) bool {
	if (end - start) != len(word) {
		return false
	}
	for i, c := range text[start:end] {
		if !(c == byte(' ') || c == word[i]) {
			return false
		}
	}
	return true
}

func reverse(s []byte) []byte {
	result := []byte{}
	for i := len(s) - 1; i >= 0; i-- {
		result = append(result, s[i])
	}
	return result
}
