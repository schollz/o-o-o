# todot

connect the dots.

todot is a synthesizer and a sequencer. it is seqeunced by connecting dots. 

more complicated explaination: each dot has an underlying rhythm that creates syncopated hits. dots are connected by [directed edges](https://en.wikipedia.org/wiki/Directed_graph). each time a dot triggers, it will emit a sound on if it has no incoming edges and has at least one outgoing edge.


this script includes a new engine "FM1" which is based of Eli Fieldsteel's [FM tutorials](https://github.com/elifieldsteel/SuperCollider-Tutorials/blob/4460e024800b6525e4223c6cce02d9643d0cfbe3/full%20video%20scripts/22_script.scd). it provides all the internal synth and percussive sounds. 


## Requirements

- norns
- grid (optional)

## Documentation

- E2 


## Install

install with

;install https://github.com/schollz/??
