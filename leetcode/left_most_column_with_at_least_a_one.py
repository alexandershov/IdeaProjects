# 10:40 started reading
# 10:42 started thinking
# 10:43 started writing
# 10:51 started checking
# 10:56 checked, no bugs


# ideas
# binary search


# """
# This is BinaryMatrix's API interface.
# You should not implement it, or speculate about its implementation
# """
#class BinaryMatrix(object):
#    def get(self, row: int, col: int) -> int:
#    def dimensions(self) -> list[]:

import math

class Solution:
    def leftMostColumnWithOne(self, binaryMatrix: 'BinaryMatrix') -> int:
        num_rows, num_columns = binaryMatrix.dimensions()
        left_most = math.inf
        for row in range(num_rows):
            row_left_most =  binary_search(binaryMatrix, row, num_columns)
            if row_left_most != -1:
                left_most = min(left_most, row_left_most)
        if left_most is math.inf:
            return -1
        return left_most


def binary_search(binaryMatrix: 'BinaryMatrix', row: int, num_columns: int) -> int:
    start = 0
    end = num_columns
    # everything before start == 0
    # everything in-bounds after and including end== 1
    while start < end:
        middle_index = (start + end) // 2
        middle_value = binaryMatrix.get(row, middle_index)
        if middle_value == 1:
            end = middle_index
        else:
            start = middle_index + 1
    if end == num_columns:
        return -1
    return end


# this runs in O(rows + columns)
class FasterSolution:
    def leftMostColumnWithOne(self, binaryMatrix: 'BinaryMatrix') -> int:
        num_rows, num_columns = binaryMatrix.dimensions()
        left_most = -1
        row = 0
        column = num_columns - 1
        while row < num_rows and column >= 0:
            value = binaryMatrix.get(row, column)
            if value == 1:
                left_most = column
                column -= 1
            else:
                row += 1
        return left_most