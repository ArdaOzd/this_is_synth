 function [ps,t] = ps_extraction(filename, FS , total_harmonics,max_freq,perc_or_melodic)

 % extract the power sprectral density of the sample at the harmonics of
 % 110 = A3
 
 % ps = powerspectrum if it is melodic, volume envelope if percussive
 % t = time vector of ps
 % filename = without '.wav'
 % FS = sampling of MIDI
 % total_harmonics 
 % max_freq 
 % perc_or_melodic = 1 melodic 0 perc
 
%  
% % clear all
% % filenames= 'Timpani';
% % 
% % total_harmonics = 30;
% % max_freq = 18000;
% % FS = 48000; % resample to this fs (of the midi)
% 

channel=1;

[an_sound,fs] = audioread(filename);
x = resample(an_sound(:,channel),FS,fs);
NDFT = 2048;
fund_freq = 110;
overlap_ratio = 63/64;
na = filename(1:end-4);
w = hamming(NDFT);
% frequencies to be analyzed
harmfreq = fund_freq*[1:total_harmonics];
harmfreq = harmfreq(harmfreq<max_freq);

if perc_or_melodic == 1
    %get the spectrogram at specific f
    [~,~,t,ps,~,~] = spectrogram(x,w,NDFT*overlap_ratio,harmfreq,FS,'yaxis');
    save(na,'ps','t')
else
    [upper, ~] = envelope(x.^2,10);
    save(na,'upper')
 end
