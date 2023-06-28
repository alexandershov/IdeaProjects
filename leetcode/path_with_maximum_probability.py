# 10:26 started reading
# 10:28 started thinking
# 10:33 started writing
# 10:40 started checking
# 10:48 checked
# 10:51 bug: maxheap instead of minheap and wrong condition when updating max_prob


import collections
import heapq


class Solution:
    def maxProbability(self, n: int, edges: list[list[int]], succProb: list[float], start: int, end: int) -> float:
        unvisited = [(-1, start)]
        max_probabilities: dict[int, float] = collections.defaultdict(float)
        graph = build_graph(n, edges, succProb)
        while unvisited:
            prob, node = heapq.heappop(unvisited)
            prob = -prob
            if prob > max_probabilities[node]:
                max_probabilities[node] = prob
            for neighbor, move_prob in graph[node]:
                neighbor_prob = prob * move_prob
                if neighbor_prob > max_probabilities[neighbor]:
                    max_probabilities[neighbor] = neighbor_prob
                    heapq.heappush(unvisited, (-neighbor_prob, neighbor))
        return max_probabilities[end]


def build_graph(n, edges, succProb):
    graph = {}
    for i in range(n):
        graph[i] = []

    for (a, b), prob in zip(edges, succProb):
        graph[a].append((b, prob))
        graph[b].append((a, prob))
    return graph
