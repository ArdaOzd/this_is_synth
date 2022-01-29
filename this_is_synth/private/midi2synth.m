function [y,Fs]=midi2synth(input,Fs,synthtype,channel,note)
%% This function is based on the modified "midi2audio" function proposed by Mr.
% Ken Schutte. The polyphony instrument type is read directly from the MIDI file:
% y = midi2audio (input, Fs)
% or it can be specified using the synthtype argument:
% y = midi2audio (input, Fs, synthtype)
% Tool type information is sold in the ninth column of the NOTES and variables
% corresponds to the instrument number according to the MIDI standard (see help.pdf).
%
% You can also use the channel argument to set the channel number, which can be
% useful because channel 10 is dedicated to percussion sound and is self-contained
% tool table.
% y = midi2audio (input, Fs, synthtype, channel)
%
% Argument note Sets all notes from your file to your choice
% specified by midi format. Such a choice is suitable for debugging e.g.
% of percussion instruments that are sold on channel 10, where for each note
% is reserved for another percussion instrument according to the table of percussion instruments (see
% page 2, MIDI_intrument_table.pdf)
% y = midi2audio (input, Fs, synthtype, channel, note)

%
% Convert midi structure to a digital waveform
%
% Inputs:
%  input - can be one of:
%    a structure: matlab midi structure (created by readmidi.m)
%    a string: a midi filename
%    other: a 'Notes' matrix (as ouput by midiInfo.m)
%
%  synthtype - string to choose synthesis method
%      passed to synth function in synth.m
%      current choices are: 'fm', 'sine' or 'saw'
%      default='fm'
%
%  Fs - sampling frequency in Hz (beware of aliasing!)
%       default =  44.1e3

% Copyright (c) 2009 Ken Schutte
% more info at: http://www.kenschutte.com/midi

if (nargin<2)
  Fs=48e3;
end

endtime = -1;
if (isstruct(input))
  [Notes,endtime] = midiInfo_polyphony(input, 0);
  Notes(:,2)=Notes(:,2)+1; % korekce - puvodni kod pocita kanaly a instrumenty od nuly
  Notes(:,9)=Notes(:,9)+1;
elseif (ischar(input))
  [Notes,endtime] = midiInfo_polyphony(readmidi(input), 0);
  Notes(:,2)=Notes(:,2)+1; % korekce - puvodni kod pocita kanaly od nuly
  Notes(:,9)=Notes(:,9)+1;
else
  Notes = input;
end

clc;
disp('Your MIDI-file contains:')
disp('=======================')
% vypis kanalu
list_of_channels=unique(Notes(:,2));
for i=1:numel(list_of_channels)
    list_of_instruments=unique(Notes(Notes(:,2)==list_of_channels(i),9));
    for j=1:numel(list_of_instruments)
        disp(['Channel ' num2str(list_of_channels(i)) ': instrument no. ' num2str(list_of_instruments(j)) ' (' num2str(sum(Notes(:,9)==list_of_instruments(j) & Notes(:,2)==list_of_channels(i))) ' notes)']); % korekce +1 kvuli pocitani od nuly
    end
    if list_of_channels(i)==10
        list_of_percussions=unique(Notes(Notes(:,2)==10,3));
        str=[];
        for k=1:numel(list_of_percussions)-1
            str=[str num2str(list_of_percussions(k)) ' (' num2str(sum(Notes(:,3)==list_of_percussions(k) & Notes(:,2)==list_of_channels(i))) ' notes)' ', ']; % korekce zjevne pocitaji od jedne, carky mezi cisly
        end
        if isempty(k)
            k = 0;
        end
        str=[str num2str(list_of_percussions(k+1)) ' (' num2str(sum(Notes(:,3)==list_of_percussions(k+1) & Notes(:,2)==list_of_channels(i))) ' notes)']; % nakonci bez carky
        disp(['            percussion no. ' str]); % korekce +1 kvuli pocitani od nuly

    end
end

if (nargin>2)
  Notes(:,9)=synthtype;
  disp('=======================')
  disp(['All channels will be synthesized with intrument no. ' num2str(synthtype)])
end

if (nargin>3)
  Notes(:,2)=channel;
  disp(['All channels will be synthesized as channel no. ' num2str(channel)])
end

if (nargin>4)
  Notes(:,3)=note;
  disp(['All notes will be synthesized as note no. ' num2str(note)])
end

% t2 = 6th col
if (endtime == -1)
    
  endtime = max(Notes(:,6));
end
if (length(endtime)>1)
  endtime = max(endtime);
end

y = zeros(1,ceil(endtime*Fs));

for i=1:size(Notes,1)

  f = midi2freq(Notes(i,3));
  dur = Notes(i,6) - Notes(i,5);
  amp = Notes(i,4)/127;
  synthtype = Notes(i,9);
  channel = Notes(i,2);
  yt = synth(f, dur, amp, Fs, synthtype, channel, Notes(i,3));

  n1 = floor(Notes(i,5)*Fs)+1;
  N = length(yt);  

  n2 = n1 + N - 1;
  
  % hack: for some examples (6246525.midi), one yt
  %       extended past endtime (just by one sample in this case)
  % todo: check why that was the case.  For now, just truncate,
  if (n2 > length(y))
    ndiff = n2 - length(y);
    yt = yt(1:(end-ndiff));
    n2 = n2 - ndiff;
  end

  % ensure yt is [1,N]:
  disp(synthtype)
%   disp(size(reshape(yt,1,[])))
%   disp(size(y(n1:n2)))
  
  y(n1:n2) = y(n1:n2) + reshape(yt,1,[]);
    
end

disp('=======================')
disp('*** It''s done! Enjoy the music :-) ***')
