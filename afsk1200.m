function [sig] = afsk1200(bits, fs, F_mark, F_space, bit_rate)
%  The function will take a bitarray of bits and will output an AFSK1200 modulated signal of them, sampled at 44100Hz
%  Dang Manh Truong (dangmanhtruong@gmail.com)
%  References:
%  [1] - https://inst.eecs.berkeley.edu/~ee123/sp17/lab/lab5/Lab5_Part_2-Audio_Frequency_Shift_Keying(AFSK).html
%      Inputs:
%             bits  - bitarray of bits
%             fs    - sampling rate
%     Outputs:
%             sig    -  returns afsk1200 modulated signal    
% 
num_of_bits = numel(bits);
F_s = lcm(fs, bit_rate);
d_alpha_mark = 2* pi*F_mark/F_s;
d_alpha_space = 2* pi*F_space/F_s;
num_of_samples_per_bit = ceil(F_s / bit_rate); 
alpha = 0;
idx = 1;
s_t = zeros(1, num_of_bits * num_of_samples_per_bit);
for ii = 1:num_of_bits
    if bits(ii)==1
        d_alpha = d_alpha_mark;
    else
        d_alpha = d_alpha_space;
    end   
    for j = 1:num_of_samples_per_bit
        alpha = alpha + d_alpha;
        s_t(idx) = cos(alpha);
        % s_t(idx) = exp(sqrt(-1) * alpha);
        idx = idx + 1;
    end
end
downsampling_rate = ceil(F_s / fs);
sig = s_t(1 : downsampling_rate : num_of_bits * num_of_samples_per_bit);
end

