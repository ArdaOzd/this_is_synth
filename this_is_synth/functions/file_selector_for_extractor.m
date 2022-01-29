
%% running this function will create .mat files for psd's of sounds
path = fullfile('C:\Users\asus\Desktop\SynthChall\Sounds\sounds_of_bohemian\percussive');
files = dir(path);
for fileIndex=1:length(files)
if (files(fileIndex).isdir == 0)
        if (~isempty(strfind(files(fileIndex).name,'wav')))
            b=fullfile(path,files(fileIndex).name)
            ps_extraction(b,48000,30, 18000, 0);
        end
end
end


