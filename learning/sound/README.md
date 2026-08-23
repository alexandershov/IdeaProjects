# Sound

## What is it?
Project that explores generating sound using programming.

## MIDI format

MIDI file is a set of instructions, it doesn't contain audio recording.
So MIDI files are really small.  
Extension is `.mid` or `.midi`.

See [midi_file.py](sound/midi_file.py) for a walkthrough of the MIDI format.
Run it with
```shell
uv run src/sound/midi_file.py --output c4.mid --notes C4
```

On Mac you can play MIDI files with `open path/to/file.mid` - it will open MIDI file in Garage Band.