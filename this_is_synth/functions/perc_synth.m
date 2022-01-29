function [out] = perc_synth(filenames,len_synth, fs, env_smoothing, hp_lp, Fcut ,noise_type)
%Author Arda Özdoğru



% % Percussion
% noise_type = 'v';
% filenames= 'triangle';
% len_synth = 2; %sec
% fs = 48000;
% Fcut = 12000;
% hp_lp = 0;
% env_smoothing = 500;

%read envelopes
filename = [filenames '.mat'];
upper_s = load(filename);
upper = upper_s.upper;
env = envelope(upper,env_smoothing,'peak');
%create envelopes
dt = 1/fs;
t = [0:dt:len_synth-dt]';
rel_aw = hamming(floor(2*length(t)/10));
if length(t) <= length(upper)
    signal = [env(1:length(t)-1); env(length(t))*rel_aw(floor((length(rel_aw)/2)+1:end))] ;
    
else
    rel_w = env(end) * rel_aw(floor((length(rel_aw)/2)+1:end));
    signal = [env(1:end-1); rel_w];
end
% create the colored noise
len = length(signal);
switch noise_type
    case 'b'
        noise = bluenoise(len);  % higher freq
    case 'p'
        noise = pinknoise(len);  % lower freq
    case 'r'
        noise = rednoise(len);  % lower feq higher power
    case 'v'
        noise = violetnoise(len);  %higher freq higher power
end

%sound
signal = signal.*noise;
%smoothing
aw = hamming(100);
signal(1:length(aw)/2) = signal(1:length(aw)/2).*aw(1:length(aw)/2);
signal(end - (length(aw)/2)+1:end,1) = signal(end - (length(aw)/2)+1:end,1).*aw((length(aw)/2)+1:end,1);

if sum(isnan(signal))>0
        save(filenames,signal);
        tau = 0.01;  % doznivani
        signal = exp(-t/tau).*bluenoise(size(t));
end
out = signal./max(abs(signal),[],'all');

end 