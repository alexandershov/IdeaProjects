# Sound

## What is it?
Project that explores generating sound using programming.

## MIDI format

MIDI file is a set of instructions, it doesn't contain audio recording.
So MIDI files are really small.  
Extension is `.mid` or `.midi`.

See [midi_file.py](src/sound/midi_file.py) for a walkthrough of the MIDI file format.
Run it with
```shell
uv run src/sound/midi_file.py --output c4.mid --notes C4
```

or for a more complicated melody:
```shell
make whats-my-age-again
```

On Mac you can play MIDI files with `open path/to/file.mid` - it will open MIDI file in Garage Band.

## MIDI stream
See [midi_stream.py](src/sound/midi_stream.py) for an example of MIDI streaming.

Start Garage Band. Create a new project and choose "MIDI Software Instrument" as project type.
Then run
```shell
make stream-whats-my-age-again
```

This setup writes a MIDI stream to Garage Band port. Garage Band then synthesizes this stream into sound.