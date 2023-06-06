# 09:34 started reading
# 09:35 started thinking
# 09:50 started writing O(m^2 * n)
# 09:58 started checking
# 10:00 checked, found a bug
# 10:02 continue, start over with brute force
# 10:06 implemented brute force, TLE as expected
# 15:58 continue with tries
# 16:30 figured out O(m * n) with two tries, started writing
# 16:45 started checking


# ideas:
# iterate over all strings in parallel and group somehow
# same prefix and same suffix
# trie

from dataclasses import dataclass
from typing import List
from typing import Optional


@dataclass
class Trie:
    char: str
    children: dict[str, 'Trie']
    parent: Optional['Trie']
    count: int



class Solution:
    def differByOne(self, dict: List[str]) -> bool:
        strings = dict
        prefix_trie = build_trie(strings)
        suffix_trie = build_trie(build_reversed_strings(strings))
        for a_string in strings:
            suffix_node = find_biggest_suffix_node(suffix_trie, a_string)
            prefix_node = prefix_trie
            if is_a_solution(suffix_node, prefix_node):
                return True
            for char in a_string:
                prefix_node = prefix_node[char]
                suffix_node = suffix_node.parent
                # TODO: DRY it up
                if is_a_solution(suffix_node, prefix_node):
                    return True
        return False


def is_a_solution(prefix_node: Trie, suffix_node: Trie) -> bool:
    # O(1) time & memory
    return prefix_node.count > 1 and suffix_node.count > 1



def build_trie(strings: list[str]) -> Trie:
    # O(n * m) time & memory
    trie = Trie(char='', children={}, parent=None, count=0)
    for a_string in strings:
        add_to_trie(a_string, trie)
    return trie

def add_to_trie(string: str, trie: Trie) -> None:
    # O(m) time & memory
    node = trie
    node.count += 1
    for char in string:
        if char not in node.children:
            node.children[char] = Trie(char=char, children={}, parent=node, count=0)
        node = node.children[char]
        node.count += 1


def build_reversed_strings(strings: list[str]) -> list[str]:
    # O(n * m) time & memory
    return [a_string[::-1] for a_string in strings]


def find_biggest_suffix_node(trie, a_string):
    # O(m) time & memory
    reversed_string = a_string[::-1]
    node = trie
    for char in reversed_string[1:]:
        node = node.children[char]
    return node
