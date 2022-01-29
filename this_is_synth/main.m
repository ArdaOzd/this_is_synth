     %% COMMAND SCRIPT FOR THE MIDI FILE READING
% Upload MIDI files into the subfolder called "midi". The subfolder
% "./private" contains additive functions for MIDI file processing. Therefore
% you do not need to solve the MIDI file reading. Your task is to design 
% a synthesis of single notes. The single notes are synthesized by the
% function "synth.m", whose body can be found in the root folder. Write 
% your solution to the synthesis in to the body of the "synth.m" flie. You 
% can find help and guidelines in the function "synth.m" header or
% "./private/midi2synth." Detailed iformation about the instrument type can
% be found in the document "MIDI_instrument_table.pdf." Results of the 
% synthesis can be found in the subfolder "./result" named after the 
% original MIDI files. 
%
% Adapted functions for the MIDI file reading are based on the original 
% design Ken Schutte (kenschutte@gmail.com), which are availablktere jsou dostupne vcetne dokumentace na 
% http://kenschutte.com/midi podle GPL.

%% Polyphonic synthesis of the single instrument (CTRL + ENTER)
% Everything is automatically uploaded from the midi file:
synthchallenge('BOHEMIAN.mid');

% The number of instrument can be manually set. Entire composition is then realised
% using a chosen instrument (useful tool for debuging):
% synthchallenge('Popelka.mid',2);
 
% The number of the instrument, and the channel can be manually set:
% synthchallenge('Popelka.mid',2,10);

% The number of instrument, the chahnnel, and the note can be manually set:
% synthchallenge('Popelka.mid', 2, 10, 1);

%% Scale


% since the melodic sounds has exponential releases the realese times are
% kept high to make it smooth, but when synthesizing the scale
% concatanetive approach made the result so long
la_major = [110 123.47  130.81  146.83  164.81  174.61  196.00];
fs = 48000;
dur = 1.5;
amp = 0.8;
% function y=synth(freq,dur,amp,Fs,synthtype,channel,note)
y = zeros(5,1);
synth_type = [1 31 34 48 49 53 56 66 61 63 70];

for type = 1:length(synth_type)
    for m = 1:3
        for note = 1:length(la_major)
            y = [y ;synth(m*la_major(note),dur,amp,fs,synth_type(type),1,1)];
        end
    end
end
y1(:,1) = y;
y2(:,2) = y;
y = y./max(y,[],'all');
audiowrite('C:\Users\asus\Desktop\This_is_synth\result\Scale1.m4a',y,fs);

%% abrupt MIDI

synthchallenge('MISSION.mid');