# 10:07 started reading
# 10:11 started thinking
# 11:06 figured out combine in "solve for subtrees and combine'
# 11:06 checking that it works on examples
# 11:12 pause
# 14:02 continue
# 14:11 combine approach is wrong
# 14:17 figured out f(n - 1, k) + f(n, k - 1)
# 14:17 started writing
# 14:37 started checking
# 14:39 checked
# 14:44 forgot about modulo and @dataclass, otherwise ok, but slow
# 14:57 hint: math.comb(n + k, n) does the job for calc_interwoven_count(n, k)

# ideas:
# solve for subtrees and combine
# store all children (separated via < and >) and allowed position range for each element, we know which elements can go on each position
# start from the leaves
# dynamic programming

# observation:
# each child should go after its parent in the permutation


from dataclasses import dataclass
from typing import Optional

MODULO = 10 ** 9 + 7


@dataclass
class Node:
    value: int
    left: Optional['Node']
    right: Optional['Node']
    tree_size: int


class Solution:
    def numOfWays(self, nums: list[int]) -> int:
        root = build_bst(nums)
        return calc_permutations(root) - 1


def calc_interwoven_count(n, k, cache) -> int:
    # this is highly inefficient way to do math.comb(n + k, n)
    if n == 0 or k == 0:
        return 1
    key = (n, k)
    if key in cache:
        return cache[key]
    count = plus_modulo(calc_interwoven_count(n - 1, k, cache), calc_interwoven_count(n, k - 1, cache))
    cache[key] = count
    return count


def calc_permutations(node: Optional[Node], cache=None) -> int:
    if node is None:
        return 1
    if cache is None:
        cache = {}  # (left_size, right_size) -> interwoven_count
    left_perm = calc_permutations(node.left, cache)
    right_perm = calc_permutations(node.right, cache)
    left_size = get_tree_size(node.left)
    right_size = get_tree_size(node.right)
    return mul_modulo(calc_interwoven_count(left_size, right_size, cache), mul_modulo(left_perm, right_perm))


def get_tree_size(node: Optional[Node]) -> int:
    if node is None:
        return 0
    return node.tree_size


def build_bst(nums: list[int]) -> Optional[Node]:
    if not nums:
        return None
    root = Node(value=nums[0], left=None, right=None, tree_size=1)
    for i in range(1, len(nums)):
        a_num = nums[i]
        insert_bst(root, a_num)
    return root


def insert_bst(node: Node, num: int):
    assert num != node.value
    node.tree_size += 1
    if num < node.value:
        if node.left is None:
            node.left = Node(value=num, left=None, right=None, tree_size=1)
        else:
            insert_bst(node.left, num)
    else:
        if node.right is None:
            node.right = Node(value=num, left=None, right=None, tree_size=1)
        else:
            insert_bst(node.right, num)


def plus_modulo(x, y):
    return ((x % MODULO) + (y % MODULO)) % MODULO


def mul_modulo(x, y):
    return ((x % MODULO) * (y % MODULO)) % MODULO
