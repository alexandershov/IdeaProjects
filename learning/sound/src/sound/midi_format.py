import argparse
import struct
from dataclasses import dataclass


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', default='/dev/stdout')
    return parser.parse_args()


@dataclass(frozen=True)
class Header:
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


def main():
    parser = parse_args()
    with open(parser.output, 'wb') as output:
        header = Header(num_tracks=1, ticks_in_quarter=96)
        output.write(header.as_bytes())

        # now our header is done - we've written exactly 6 bytes of data
        # let's define a track
        # first is ascii encoding of "MTrk" ("MIDI Track chunk")
        output.write(b"MTrk")
        # then 4-byte length of the track in big-endian
        # length is 12 bytes for us
        output.write(struct.pack(">i", 12))
        # Let's add events to our track
        # events are essentially a pair {ticks after the previous event, event}
        # number of ticks is 1 byte, here zero ticks after the previous event
        output.write(struct.pack(">B", 0))
        # 1001 means "note on" (== we start playing a note)
        # 0000 is channel number, there are 16 channels in total
        # we use channel 0
        output.write(struct.pack(">B", 0b10010000))
        # next is the note, 60 means C4 - it's a C note in 4th octave
        # MIDI notes are described here: https://inspiredacoustics.com/en/MIDI_note_numbers_and_center_frequencies
        output.write(struct.pack(">B", 60))
        # next byte is how forcefully the note was played (velocity)
        output.write(struct.pack(">B", 64))
        # previous 4 bytes were an event: "start playing note C4 on channel 0 with the 64 velocity"
        # next 4 bytes describe an event "stop playing C4 on channel 0 after 96 ticks"
        # ticks after the previous event
        output.write(struct.pack(">B", 96))
        # note off on channel 0
        output.write(struct.pack(">B", 0b10000000))
        # 60 (== C4) is the note that we stop playing
        output.write(struct.pack(">B", 60))
        # next byte is how quickly the note was released (release velocity)
        output.write(struct.pack(">B", 64))
        # ticks after previous event
        output.write(struct.pack(">B", 0))
        # 255 means "meta event"
        output.write(struct.pack(">B", 255))
        # 47 means "end of track"
        output.write(struct.pack(">B", 47))
        # 0 means that this meta event has 0 bytes of a payload
        output.write(struct.pack(">B", 0))
        # on a high level the file we just wrote represents 2 musical events:
        # play a note C4 on a channel 0
        # after 0.5 seconds stop playing note C4 on a channel 0


if __name__ == '__main__':
    main()