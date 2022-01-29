function [output] = melodic_synth(filename,fs, input_f, total_harmonics,...
                         len_synth, rel_len, max_freq,pan,filter_type,Fcut)

% filename = 'Piano';
% fs = 48000;
% input_f = 110;
% total_harmonics = 25;
% len_synth = 1.5;
% rel_len = 3 ;
% max_freq = 18000;
% filter_type = 1;
% Fcut = 10000;

if (contains(filename,'.wav'))
    na_me = filename(1:end-4);
    ps_name = [na_me '.mat'];
else
        ps_name = [filename '.mat'];
end
ps_interp1_s = load(ps_name);
ps_interp1  = ps_interp1_s(:,:).ps; 
t = ps_interp1_s(:,:).t;

dt = 1/fs;
% NDFT = 2048;
fund_freq = 110;
t_synth = [0:dt:len_synth-dt]';

% frequencies to be analyzed
harmfreq = fund_freq*[1:total_harmonics];
harmfreq = harmfreq(harmfreq<max_freq);
harmfreq_ratio = harmfreq./harmfreq(1);


for i= 1:length(ps_interp1(:,1))
% %     xxx = zeros(1,length(ps_interp1(1,:)));
        ps_interp2(i,:) = interp1(t,ps_interp1(i,:),t_synth','spline','extrap');
    min_p = min(ps_interp2(i,:));
    for k = 1:length(ps_interp2(i,:))
        if isnan(ps_interp2(i,k))
            ps_interp2(i,k) = min_p;
        end
    end
ps_interp(i,:) = ps_interp2(i,:);
end

% definitions
gen_len = length(t_synth);
gen_sound = zeros(gen_len,1);

% release envelop
rel_t = [0:dt:rel_len-dt]';
rel_phase = [t_synth(gen_len):dt:t_synth(gen_len)+rel_len-dt]';
rel_env = zeros(length(rel_t),1);

% frequencies to be synthesized
synth_f = harmfreq_ratio*input_f;
synth_f = synth_f(synth_f<max_freq);



%  figure(9)
for i = 1:length(synth_f)
    
   [upper, ~] = envelope(ps_interp(i,:),10);
   
    if gen_len <= length(upper)
        sine_wave = zeros(gen_len,1);
        sine_wave = upper(1:gen_len-1)'.*(sin(2*pi*synth_f(i).*t_synth(1:gen_len-1)));%+ (10^(-3))/length(synth_f)*noise);                                                                     
    else   
        sine_wave1 = zeros(length(upper),1);
        sine_wave1 = upper(1:end-1)'.*(sin(2*pi*synth_f(i).*t_synth(1:length(upper)-1)));
        h_c = hamming(2*(gen_len - length(upper)));
        sine_wave = [sine_wave1 ; sine_wave1(end)*h_c((length(h_c)/2)+1:end)];
    end
    
    if length(gen_sound) > length(sine_wave)
        gen_sound(1:length(sine_wave)) = gen_sound(1:length(sine_wave)) + sine_wave;
    elseif length(gen_sound) < length(sine_wave)
        gen_sound = gen_sound + sine_wave(1:length(gen_sound));
    else
        gen_sound = gen_sound + sine_wave;
    end
    
        % create release envelop
        if abs(gen_sound(end)) == 0
            rel_aw = hamming(2*length(rel_t));
           rel = (mean(upper)*exp(-4*rel_t).*(sin(2*pi*synth_f(i).*rel_phase)));
           rel(end-(length(rel_aw)/2)+1:end) = rel(end-(length(rel_aw)/2)+1:end).*rel_aw((length(rel_aw)/2)+1:end);
           rel_env = rel_env + rel;
        else
            rel_a = -abs(log((10^-2)/abs(gen_sound(end)))/rel_len);   %bigger number for harder release
            rel_env = rel_env + upper(end)*exp(rel_a*rel_t).*(sin(2*pi*synth_f(i).*rel_phase));
        end
         
end
%  hold off
signal = [gen_sound(1:end-1); rel_env];
% Filter options
passband= Fcut/(fs/2);

stopband = 2*Fcut/(fs/2);

if stopband >=1
    stopband=0.99;
    passband = 0.4;
end
Rp = 1;
Rs = 40;
if filter_type == 3
    [Ne, We] = ellipord(passband, stopband, Rp, Rs);
    [H,G] = ellip(Ne,Rp,Rs,We,'low');
    signal = filter(H,G,signal);
elseif filter_type == 2
    [Nc2, Wc2] = cheb2ord(passband, stopband, Rp, Rs);
    [F,E] = cheby2(Nc2,Rs,Wc2,'low');
    signal = filter(F,E,signal);
elseif filter_type == 1
    [Nc1, Wc1] = cheb1ord(passband, stopband, Rp, Rs);
    [D,C] = cheby1(Nc1,Rp,Wc1,'low');
    signal = filter(D,C,signal);
else 
end


try
    olen = floor(16*2*10^(-3)*fs);
    atack_steep = 0.5 ;% higher exponential like, lower linear like
    h = 2.^(atack_steep*t_synth(1:olen))';
    h = h./max(h);
    windo_a = h(1:olen)';

    h1 = hamming(olen);
    windo_r = h1(round((olen/2))+1:end);

    signal1 = signal./ max(abs(signal),[],'all');
    signal2 = [zeros(floor(0.001*fs),1) ; signal1];
    signal2(1:length(windo_a)) = signal2(1:length(windo_a)).*windo_a;
    signal2(end-length(windo_r)+1:end) = signal2(end - length(windo_r)+1:end).*windo_r;

catch

    signal1 = signal./ max(abs(signal),[],'all');
    signal2 = [zeros(floor(0.001*fs),1) ; signal1];

end

if sum(isnan(signal2))>0
    output(:,1) = zeros(length(signal2),1);
else
    output(:,1) = signal2;
end
end


