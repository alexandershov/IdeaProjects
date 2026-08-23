import abc
import argparse
import struct
from dataclasses import dataclass

# excerpts from https://inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
MIDI_NOTE = {
    # note B in the 3rd octave
    "B3": 59,
    # note F# in the 4th octave, F# is one semitone higher than F
    "F#4": 66,
    "A#4": 70,
    "F#3": 54,
    "C#3": 49,
    "D#3": 51,
    "C4": 60,
}


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--notes", type=_parse_notes)
    parser.add_argument('--velocity', default=64, type=int)
    parser.add_argument('--note-ticks', default=96, type=int)
    parser.add_argument('--output', default='/dev/stdout')
    return parser.parse_args()


def _parse_notes(s: str) -> list[str]:
    return s.split(" ")


class MIDIItem(abc.ABC):
    @abc.abstractmethod
    def as_bytes(self) -> bytes:
        raise NotImplementedError


@dataclass(frozen=True)
class Header(MIDIItem):
    num_tracks: int
    ticks_in_quarter: int

    def as_bytes(self) -> bytes:
        parts: list[bytes] = [
            # each MIDI file starts with the header.
            # Header starts with the bytes 0x4d, 0x54, 0x68, 0x64
            # these bytes actually can be represented by ascii encoding of
            # the string "MThd", "hd" stands for "header"
            b"MThd",
            # next is the length of the header in bytes
            # note the length of the header doesn't include MThd and the length field itself
            # length is 4-byte integer in big-endian order (least significant byte is last)
            # if e.g. length of the header is 6, then we'll get
            # 0x00, 0x00, 0x00, 0x06
            struct.pack(">i", 6),
            # next 2 bytes encode format.
            # format==0 means that everything is recorded in 1 track
            # 0x00, 0x00
            struct.pack(">h", 0),
            # next 2 bytes encode number of tracks
            # e.g. for 1 track it's 0x00, 0x01
            struct.pack(">h", self.num_tracks),
            # next 2 bytes define how many ticks are in a quarter of the note
            # ticks are abstract unit - they're not seconds
            # we can define what a tick is, by default quarter of a note is 0.5 seconds
            # so our tick is 0.5s/96
            struct.pack(">h", self.ticks_in_quarter),
        ]
        return b"".join(parts)


@dataclass(frozen=True)
class NoteEvent(MIDIItem):
    delta_ticks: int
    on: bool
    note: str
    channel: int
    velocity: int

    def as_bytes(self) -> bytes:
        assert 0 <= self.delta_ticks <= 255
        midi_note = MIDI_NOTE[self.note]
        assert 0 <= midi_note <= 255
        assert 0 <= self.channel <= 15
        assert 0 <= self.velocity <= 255
        parts: list[bytes] = [
            # events are essentially a pair {ticks after the previous event, event}
            # number of ticks is 1 byte
            struct.pack(">B", self.delta_ticks),
            # 1001 means "note on" (== we start playing a note)
            # 1000 means "note on" (== we stop playing a note)
            struct.pack(">B", ((0b10010000 if self.on else 0b10000000) | self.channel)),
            # next is the note
            struct.pack(">B", midi_note),
            # next byte is how forcefully the note was played (velocity)
            struct.pack(">B", self.velocity),
        ]
        return b"".join(parts)


@dataclass(frozen=True)
class MetaEvent(MIDIItem):
    delta_ticks: int
    sub_type: int

    def as_bytes(self) -> bytes:
        assert 0 <= self.delta_ticks <= 255
        parts: list[bytes] = [
            # ticks after previous event
            struct.pack(">B", self.delta_ticks),
            # 255 means "meta-event"
            struct.pack(">B", 255),
            struct.pack(">B", self.sub_type),
            # 0 means that this meta-event has 0 bytes of a payload
            struct.pack(">B", 0),
        ]
        return b"".join(parts)


@dataclass(frozen=True)
class Track(MIDIItem):
    events: list[MIDIItem]

    def as_bytes(self):
        event_parts: list[bytes] = []
        for an_event in self.events:
            event_parts.append(an_event.as_bytes())

        # 47 means "end of track"
        event_parts.append(MetaEvent(delta_ticks=0, sub_type=47).as_bytes())

        events_as_bytes = b"".join(event_parts)

        parts: list[bytes] = [
            # first is ascii encoding of "MTrk" ("MIDI Track chunk")
            b"MTrk",
            # then 4-byte length of the track in big-endian
            # it's sum of all events
            struct.pack(">i", len(events_as_bytes)),
            # and now the events themselves
            events_as_bytes,
        ]
        return b"".join(parts)


def main():
    args = parse_args()
    with open(args.output, 'wb') as output:
        header = Header(num_tracks=1, ticks_in_quarter=96)
        # each MIDI file starts with the header
        output.write(header.as_bytes())

        events = []
        for note in args.notes:
            # start playing the given note
            note_on = NoteEvent(delta_ticks=0, on=True, note=note, channel=0, velocity=args.velocity)
            # stop playing the given note after the specified number of ticks
            note_off = NoteEvent(delta_ticks=args.note_ticks, on=False, note=note, channel=0, velocity=args.velocity)
            events.extend([note_on, note_off])

        track = Track(events=events)
        # track comes after the header
        output.write(track.as_bytes())


if __name__ == '__main__':
    main()
