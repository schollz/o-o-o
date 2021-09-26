# o-o-o

connect the dots.

o-o-o (*oh-dasho-dasho*) is a fm-based synthesizer and a sequencer. 


## Requirements

- norns
- grid (optional)

## Documentation

- E1 changes instrument
- E2/E3 changes position
- K3 adds connection
- K2 cancels connection
- K1+K3 pauses instrument
- K1+K2 removes all connections

each dot has an underlying random euclidean rhythm. the rhythm is randomly generated based on a seed. each dot is capable of triggering a sound. the sounds that are triggered are all based on an internal FM sound engine (based on Eli Fieldsteel's [FM tutorials](https://github.com/elifieldsteel/SuperCollider-Tutorials/blob/4460e024800b6525e4223c6cce02d9643d0cfbe3/full%20video%20scripts/22_script.scd) snippets). 

sounds are triggered when dots are connected. a dot will trigger a sound if it is connected to another dot. upon triggering, it will "arm" all connections coming *from* that dot. when a connection is armed, it will cause a dot to trigger the next time the rhythm of that dot hits a beat. connections curved up or curved left are going left to right, or down to up, respectively. connections curved down or curved right are going right to left or up to down, respectively.

there are gradients in the rows and columns. these are hard-coded in the script, but you can easily change the behavior through maiden. currently they are coded so that columns on the left typically trigger slower (except pads) and columns on the right trigger faster. rows on the bottom are lower notes and rows at the top are higher notes (except pads). pads are special - each dot actually represents two intervals, where the row specifies root and the column specifies the other two intervals.


## Install

install with

;install https://github.com/schollz/o-o-o
