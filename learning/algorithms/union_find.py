# the idea of union find is this:
# we store disjoint sets
# each element belongs to a set. Set can be a singleton
# each set has a leader
# each element has a parent
# leader's parent is itself
# when we union two sets, we attach leader of the smaller set to the leader of the larger set
# this is optimization that allows O(log) find operations
# there's another optimization where we compress path (when we traverse path from element to its leader
# then we can point each element on the way directly to its leader
# we can do it during find, it leads O(reverse_ackerman(n)) complexities, but good luck proving this.
# reverse_ackerman is very slow growing functions, for practical purposes we can consider it constant
# TODO: add a practical example where union find is useful

class UnionFind:
    def __init__(self):
        self._parents = {}
        self._sizes = {}

    def add(self, key):
        try:
            leader = self.find(key)
        except KeyError:
            self._parents[key] = key
            self._sizes[key] = 1
            return key
        else:
            return leader

    def find(self, key):
        if key not in self._parents:
            raise KeyError(f"{key} not found")
        while self._parents[key] != key:
            key = self._parents[key]
        return key

    def union(self, a, b):
        a_leader = self.find(a)
        b_leader = self.find(b)
        if a_leader == b_leader:
            return a_leader
        a_size = self._sizes[a_leader]
        b_size = self._sizes[b_leader]
        # we always attach small to large
        # this allows for paths that are max log(N)
        # proof:
        # let's take the longest path, it has X edges
        # each edge connects small to large, this means
        # let small size to be N, then the size of large + small is at least 2 * N
        # each edge doubles size, after X edges we'll have the total size of all related sets to be
        # 2^X, so X is log(total_size).
        # Would we attach large to small instead, then each edge could increase size by just 1,
        # since small size can be 1
        if a_size < b_size:
            self._parents[a_leader] = b_leader
            self._sizes[b_leader] += self._sizes[a_leader]
            return b_leader
        else:
            self._parents[b_leader] = a_leader
            self._sizes[a_leader] += self._sizes[b_leader]
            return a_leader


def test_union_find():
    uf = UnionFind()
    for i in range(10):
        uf.add(i)
    leader_01 = uf.union(0, 1)
    leader_012 = uf.union(leader_01, 2)
    leader_34 = uf.union(3, 4)
    leader_345 = uf.union(leader_34, 5)
    leader_3456 = uf.union(leader_345, 6)
    leader_0123456 = uf.union(leader_01, leader_3456)

    assert leader_01 == 0
    assert leader_012 == 0
    assert leader_34 == 3
    assert leader_345 == 3
    assert leader_3456 == 3
    assert leader_0123456 == 3

    # 3 is a leader of 0123456
    assert uf.find(0) == 3
    assert uf.find(1) == 3
    assert uf.find(2) == 3
    assert uf.find(3) == 3
    assert uf.find(4) == 3
    assert uf.find(5) == 3
    assert uf.find(6) == 3

    assert uf.find(7) == 7
