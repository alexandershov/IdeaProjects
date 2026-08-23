import argparse
import asyncio
import sys
import termios
import tty

# rtmidi allows us to write MIDI messages into MIDI ports on our system
# it's a wrapper over https://github.com/thestk/rtmidi
import rtmidi

from sound.midi_file import MIDI_NOTE
from sound.midi_file import NoteEvent
from sound.midi_file import parse_notes

MIDI_NOTE_BY_NUMBER = dict(enumerate(MIDI_NOTE))


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
    try:
        midiout.open_port(midiout.get_ports().index(args.midi_port_name))
    except ValueError:
        raise SystemExit(f"MIDI port {args.midi_port_name!r} not found, available ports: {midiout.get_ports()!r}")

    with midiout:
        async for note in iter_notes(args):
            # in MIDI stream we don't need ticks, everything is real-time
            note_on = NoteEvent(delta_ticks=None, on=True, note=note, channel=0, velocity=args.velocity)
            midiout.send_message(note_on.as_bytes())

            # no ticks, just sleep
            await asyncio.sleep(args.note_duration_seconds)

            note_off = NoteEvent(delta_ticks=None, on=False, note=note, channel=0, velocity=args.velocity)
            midiout.send_message(note_off.as_bytes())


async def iter_notes(args):
    # return args.notes if they're available
    if args.notes is not None:
        for note in args.notes:
            yield note
        return

    # read notes from terminal in unbuffered mode
    loop = asyncio.get_running_loop()
    queue = asyncio.Queue()

    def read_stdin():
        char = sys.stdin.read(1)
        queue.put_nowait(char)

    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        # put terminal in a cbreak mode - all (mostly, except for Ctrl-C etc) keypresses are immediately available for read
        tty.setcbreak(fd)
        # calls read_stdin when fd has read availability
        loop.add_reader(fd, read_stdin)
        while True:
            char = await queue.get()
            try:
                note = MIDI_NOTE_BY_NUMBER[int(char)]
            except ValueError:
                print(f"ignoring {char} - not a number")
            except KeyError:
                print(f"ignoring {char} - unknown note")
            else:
                yield note
    finally:
        loop.remove_reader(fd)
        # restore old terminal settings, TCSADRAIN means - change attributes after transmitting all queued output.
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


if __name__ == '__main__':
    asyncio.run(amain())
