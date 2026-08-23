whats-my-age-again:
	uv run src/sound/midi_file.py  \
	 --notes "B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4" \
	 --note-duration-ticks 36 \
	 --output whats-my-age-again.mid


stream-whats-my-age-again:
	uv run src/sound/midi_stream.py  \
     --midi-port-name "GarageBand Virtual In" \
	 --notes "B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4 B3 F#4 A#4 F#4 F#3 F#4 A#4 F#4 C#3 F#4 A#4 F#4 D#3 F#4 A#4 F#4" \
	 --note-duration-seconds 0.1875
     # 36ticks * 0.5s/96ticks == 0.1875 seconds
