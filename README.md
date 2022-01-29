# this_is_synth
Analyzes sounds and synthesizes song from MIDI (functions are not general but can be manipulated easily)

This Synthesizer can select the wav files in a folder and extract their power spectrum to create amplitude envelopes for the interpolated time scales based on sampling frequency independent MIDI file and saves the files in .m4a format.

Used methods
•	Power Spectral Density Envelopes on harmonics of fundamental frequency of   110Hz == A2.
•	Additive Synthesis
•	Sound Volume Envelope Extraction for percussive elements
•	Colored Noise Generation (external function)

Setup
•	Add all folder and subfolders to the path 
•	Run main.m

Note : Each sounds power spectrum for the given input number of harmonics of 110Hz (110*k)  is extracted previously and added to the folder for efficiency. If desired, can again be synthesized through helper functions.


For more info read the read me in the folder.
