# 12:50 started reading
# 12:51 started thinking
# 12:54 started writing
# 13:08 started checking
# 13:11 checked
# 13:13 got a couple of typos and bad return from iter_diagonal


UP_RIGHT = (-1, 1)
DOWN_LEFT = (1, -1)

import itertools

class Solution:
    def findDiagonalOrder(self, mat: list[list[int]]) -> list[int]:
        if not mat:
            return []

        result = []
        num_rows = len(mat)
        num_columns = len(mat[0])

        directions = itertools.cycle([UP_RIGHT, DOWN_LEFT])
        row, column = 0, 0
        while len(result) != num_rows * num_columns:
            cur_direction = next(directions)
            for item, (item_row, item_column) in iter_diagonal(mat, row, column, cur_direction):
                result.append(item)
                row, column = item_row, item_column
            row, column = move(num_rows, num_columns, row, column, cur_direction)

        return result


def iter_diagonal(mat, row, column, direction):
    while is_in_bounds(mat, row, column):
        yield mat[row][column], (row, column)
        row, column = apply_direction(row, column, direction)


def apply_direction(row, column, direction):
    row_delta, column_delta = direction
    return row + row_delta, column + column_delta

def is_in_bounds(mat, row, column):
    num_rows = len(mat)
    num_columns = len(mat[0])
    return (0 <= row < num_rows) and (0 <= column < num_columns)


def move(num_rows, num_columns, row, column, direction):
    if direction == UP_RIGHT:
        if column + 1 < num_columns:
            return row, column + 1
        else:
            return row + 1, column
    elif direction == DOWN_LEFT:
        if row + 1 < num_rows:
            return row + 1, column
        else:
            return row, column + 1
    else:
        raise ValueError(f'bad {direction=}')
