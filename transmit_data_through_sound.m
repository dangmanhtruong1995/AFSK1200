% Transmit data through sound using AFSK (continuous Audio Frequency Shift Keying)
% Dang Manh Truong (dangmanhtruong@gmail.com)
% References:
% [1] - https://inst.eecs.berkeley.edu/~ee123/sp17/lab/lab5/Lab5_Part_2-Audio_Frequency_Shift_Keying(AFSK).html
% [2] - A high-performance sound-cart AX.25 Modem - Sivan Toledo

rng('default'); % For reproducibility
rng(1);

% input_str = 'Cong hoa xa hoi chu nghia Viet Nam. Doc lap tu do hanh phuc';
input_str = 'Thong tin vo tuyen. QPAM. PAM...';
ascii_list = double(input_str); % https://www.mathworks.com/matlabcentral/answers/298215-how-to-get-ascii-value-of-characters-stored-in-an-array
bits = [];
for i = 1:numel(ascii_list)
    bit = de2bi(ascii_list(i), 8, 'left-msb');
    bits = [bits bit];
end

fs = 48000; % Sampling rate
F_mark = 1200;
F_space = 2200;
bit_rate = 1200;

% Transmit data
modulated_signal_at_48000 = afsk1200(bits, fs, F_mark, F_space, bit_rate);
fprintf('Modulated signal: \n');
sound(modulated_signal_at_48000, fs);
pause
mean_of_noise = 0;
standard_deviation_of_noise = 1;
noise = mean_of_noise + standard_deviation_of_noise * randn(1,numel(modulated_signal_at_48000));
modulated_signal_at_48000_with_noise = modulated_signal_at_48000 + noise;
fprintf('Modulated signal with noise: \n');
sound(modulated_signal_at_48000_with_noise, fs);
modulated_signal_at_48000_with_noise = -1 + 2.*(modulated_signal_at_48000_with_noise - min(modulated_signal_at_48000_with_noise))./(max(modulated_signal_at_48000_with_noise) - min(modulated_signal_at_48000_with_noise));
audiowrite('modulated_signal_with_noise.wav', modulated_signal_at_48000_with_noise, fs);
clear
fclose all

% Receive data
fs = 48000; % Sampling rate
F_mark = 1200;
F_space = 2200;
bit_rate = 1200;
nudge_factor = 0.75;
[modulated_signal_at_48000_with_noise, fs] = audioread('modulated_signal_with_noise.wav');
demodulator = afsk1200_demodulator(fs);
[demodulated_signal,~,~] = demodulator.demodulate(modulated_signal_at_48000_with_noise);
idx = PLL(demodulated_signal, nudge_factor, fs, bit_rate);
sampled_data_from_demodulated_signal = demodulated_signal(idx);
digital_output = sampled_data_from_demodulated_signal > 0;
% Convert to characters 
total_num_of_bits = numel(digital_output);
total_num_of_characters = total_num_of_bits / 8;
first_idx = 0;
last_idx = 0;
output_str = '';
for i = 1:total_num_of_characters
    first_idx = last_idx + 1;
    last_idx = first_idx + 7;
    binary_repr = digital_output(first_idx:last_idx); 
    ascii_value = bi2de(binary_repr(:)', 'left-msb');  
    character = char(ascii_value);        
    output_str = [output_str character];    
end
output_str
