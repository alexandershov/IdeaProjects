# 12:17 started reading
# 12:18 started reading
# 12:30 started writing
# 12:36 start checking
# 12:40 checked
# 12:41 bug, wrong global last_day

# ideas:
# dp on days
# dp on events
# sort events
# greedy


import collections
import heapq


class Solution:
    def maxEvents(self, events: list[list[int]]) -> int:
        events_by_first_day = group_events_by_first_day(events)
        first_day = min(first for first, _ in events)
        last_day = max(last for _, last in events)
        active_events = []  # heap
        max_count = 0
        for cur_day in range(first_day, last_day + 1):
            for an_event_first_day, an_event_last_day in events_by_first_day[cur_day]:
                heapq.heappush(active_events, an_event_last_day)

            while active_events:
                last_day = heapq.heappop(active_events)
                is_active = last_day >= cur_day
                if is_active:
                    max_count += 1
                    break
        return max_count


def group_events_by_first_day(events):
    grouped = collections.defaultdict(list)
    for first_day, last_day in events:
        grouped[first_day].append((first_day, last_day))
    return grouped
