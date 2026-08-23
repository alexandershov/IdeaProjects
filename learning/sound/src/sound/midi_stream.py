import argparse
import asyncio

# rtmidi allows us to write MIDI messages into MIDI ports on our system
# it's a wrapper over https://github.com/thestk/rtmidi
import rtmidi

from sound.midi_file import NoteEvent
from sound.midi_file import parse_notes


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--notes", type=parse_notes)
    parser.add_argument("--midi-port-name", required=True)
    parser.add_argument('--note-duration-seconds', type=float)
    parser.add_argument('--velocity', type=int, default=64)
    return parser.parse_args()


async def amain():
    args = parse_args()
    midiout = rtmidi.MidiOut()
    # get_ports() is e.g. ['IAC Driver Bus 1', 'GarageBand Virtual In']
    midiout.open_port(midiout.get_ports().index(args.midi_port_name))

    with midiout:
        for note in args.notes:
            # in MIDI stream we don't need ticks, everything is real-time
            note_on = NoteEvent(delta_ticks=None, on=True, note=note, channel=0, velocity=args.velocity)
            midiout.send_message(note_on.as_bytes())

            # no ticks, just sleep
            await asyncio.sleep(args.note_duration_seconds)

            note_off = NoteEvent(delta_ticks=None, on=False, note=note, channel=0, velocity=args.velocity)
            midiout.send_message(note_off.as_bytes())


if __name__ == '__main__':
    asyncio.run(amain())
