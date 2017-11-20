function [idx] = PLL(NRZa, a, fs, bit_rate)    
%     This function implements a simple phased lock loop for timing recovery
%     Dang Manh Truong (dangmanhtruong@gmail.com
%     References:
%     [1] - https://inst.eecs.berkeley.edu/~ee123/sp17/lab/lab5/Lab5_Part_2-Audio_Frequency_Shift_Keying(AFSK).html
%     Inputs:
%              NRZa -   The NRZ signal
%              a - nudge factor
%              fs - sampling rate (arbitrary)
%              bit_rate  - the bit rate
%     
%     Outputs:
%              idx - array of indexes to sample at
num_of_input_samples = numel(NRZa);
increment = (2^32) / (fs / bit_rate);
threshold_for_overflow = 2^31 - 1;
lowest_int32 = 0 - 2^31;
counter = 0;
delayed_counter = 0;
idx = [];
idx_counter = 1;
delayed_input_signal = 0;
first_time = 1;
for i = 1:num_of_input_samples
    input_signal = NRZa(i);
    is_zero_crossing = ((input_signal * delayed_input_signal <= 0) && (first_time == 0));    
    if is_zero_crossing
        multiplying_factor = a;
    else
        multiplying_factor = 1;
    end
    if first_time == 1
        counter = 0;
    else
        counter = (delayed_counter * multiplying_factor) + increment;
        % I had to do this because unlike Python, Matlab does not support
        % genuine integer overflow ....
        if counter > threshold_for_overflow
            offset = counter - threshold_for_overflow;
            counter = lowest_int32 + offset - 1;
        end   
    end
    is_overflow = ((delayed_counter >= 0) && (counter < 0));
    if is_overflow
        idx = [idx i];
    end   
    if first_time == 1
        first_time = 0;
    end
    delayed_counter = counter;
    delayed_input_signal = input_signal;
end

end

