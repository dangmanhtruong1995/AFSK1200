% https://inst.eecs.berkeley.edu/~ee123/sp15/lab/lab6/Lab6-Part-A-Audio-Frequency-Shift-Keying.html
% Lab 6, Digital Communication with Audio Frequency Shift Keying (AFSK)
% Tested on Matlab R2013b
% Dang Manh Truong (dangmanhtruong@gmail.com)
fs = 48000; % Sampling rate
F_mark = 1200;
F_space = 2200;
bit_rate = 1200;

rng('default'); % For reproducibility
rng(1);
bits = randi(2,1,4096); % Random stream of bits
bits = bits - 1;

modulated_signal_at_48000 = afsk1200(bits, fs, F_mark, F_space, bit_rate);
plot(modulated_signal_at_48000(1:900),'b');
hold on
plot(zeros(1,900),'r'); % Reference line
title('Modulated signal at 48000 hz');
pause 

mean_of_noise = 0;
standard_deviation_of_noise = 1;
noise = mean_of_noise + standard_deviation_of_noise * randn(1,numel(modulated_signal_at_48000));
modulated_signal_at_48000_with_noise = modulated_signal_at_48000 + noise;
figure
plot(modulated_signal_at_48000_with_noise(1:900),'b');
hold on
plot(zeros(1,900),'r'); % Reference line
title('Modulated signal at 48000 hz with standard noise :( ');
pause

demodulator = afsk1200_demodulator(fs);
[demodulated_signal ,output_of_BP_filter_1, output_of_BP_filter_2] = demodulator.demodulate(modulated_signal_at_48000_with_noise);
[demodulated_signal_reference ,output_of_BP_filter_1_reference, output_of_BP_filter_2_reference] = demodulator.demodulate(modulated_signal_at_48000);

figure
plot(1:3000, output_of_BP_filter_1_reference(1:3000),'b');
hold on
plot(1:3000, output_of_BP_filter_2_reference(1:3000),'g'); 
title('Mark and space filter output in an ideal environment');
legend('Mark', 'Space');
pause

figure
analog_NRZ_reference = output_of_BP_filter_1_reference - output_of_BP_filter_2_reference;
plot(1:3000, analog_NRZ_reference(1:3000),'g');
hold on
plot(1:3000,zeros(1,3000),'r'); % Reference line
title('Demodulated output in an ideal environment');
pause

figure
plot(1:3000, demodulated_signal_reference(1:3000),'g');
hold on
plot(1:3000, demodulated_signal(1:3000),'b');
plot(1:3000, zeros(1,3000),'r'); % Reference line
title('Comparison of demodulated output with and without noise');
plot(1:3000, demodulated_signal_reference(1:3000),'g');
legend('Without noise', 'With noise');
stem(1:ceil(fs / bit_rate):3000, demodulated_signal(1:ceil(fs / bit_rate):3000), 'filled', 'LineStyle','-.');
pause

figure 
plot(1:1000, demodulated_signal_reference(1:1000),'g');
hold on
counter = 0;
counter_list = zeros(1,1000);
threshold_for_overflow = 2^31 - 1;
lowest_int32 = 0 - 2^31;
increment = (2^32) / (fs / bit_rate);
for i = 1:1000
    counter_list(i) = counter;
    counter = counter + increment;    
    % I had to do this because unlike Python, Matlab does not support
    % genuine integer overflow ....
    if counter > threshold_for_overflow
        offset = counter - threshold_for_overflow;
        counter = lowest_int32 + offset - 1;
    end   
end
plot(1:1000, (counter_list ./ (2^33)) * (0.4 / 0.25),'r');
plot(1:1000, zeros(1,1000),'k');
title('Ideal PLL counter overlaid on demodulated signal');
legend('Demodulated signal', 'Ideal PLL counter');
pause

figure
sample_demodulated_signal = importdata('sample_NRZ.txt');
plot(1:numel(sample_demodulated_signal), sample_demodulated_signal,'g');
hold on
idx = PLL(sample_demodulated_signal, 0.75, fs, bit_rate);
stem(idx, sample_demodulated_signal(idx), 'filled', 'LineStyle','-.');
title('An example of PLL (phase-locked loop)');
legend('Sample demodulated signal', 'PLL-sampled points');
pause