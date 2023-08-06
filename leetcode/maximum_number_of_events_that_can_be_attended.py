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
    # (days + n)*log(n)
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


class Solution:
    def maxEvents(self, events: list[list[int]]) -> int:
        events_by_day = build_events_by_day()
        active_events = []
        prev_day = 0
        max_count = 0
        for cur_day in build_days(events):
            for start, end in events_by_day[cur_day]:
                heapq.heappush(active_events, end)

            num_days = cur_day - prev_day + 1
            while active_events and active_events[0] <= cur_day:
                if num_days > 0:
                    num_days -= 1
                    max_count += 1
                heapq.heappop(active_events)
            prev_day = cur_day
        return max_count


def build_events_by_day(events):
    result = collections.defaultdict(list)
    for start, end in events:
        result[start].append((start, end))
    return result


def build_days(events):
    days = set()
    for start, end in events:
        days.add(start)
        days.add(end)
    return sorted(days)




def group_events_by_first_day(events):
    grouped = collections.defaultdict(list)
    for first_day, last_day in events:
        grouped[first_day].append((first_day, last_day))
    return grouped
