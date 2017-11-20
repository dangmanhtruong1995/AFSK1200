classdef afsk1200_demodulator < handle
    % Demodulator using AFSK1200 (continuous Audio Frequency Shift Keying)
    % Dang Manh Truong (dangmanhtruong@gmail.com)
    % References: 
    % [1] https://inst.eecs.berkeley.edu/~ee123/sp17/lab/lab5/Lab5_Part_2-Audio_Frequency_Shift_Keying(AFSK).html
    
    properties
        fs;       
        LP_filter;
        BP_filter_1;
        BP_filter_2;
        optional_lowpass_filter;
    end
    
    methods
        function obj = afsk1200_demodulator(fs)
            obj.fs = fs;
            % Hard-coded to make my life easier :)
            F_mark = 1200;
            F_space = 2200;            
            filter_order = 61;
            obj.LP_filter = fir1(filter_order, (2*600)/fs, 'low');
            length_of_filter = filter_order + 1;
            obj.BP_filter_1 = obj.LP_filter .* exp((2*pi*1j*F_mark*(1:length_of_filter))/fs);
            obj.BP_filter_2 = obj.LP_filter .* exp((2*pi*1j*F_space*(1:length_of_filter))/fs);
            obj.optional_lowpass_filter = fir1(filter_order, (2*1200*1.2)/fs, 'low');
        end
        
        function [analog_NRZ,output_of_BP_filter_1,output_of_BP_filter_2] = demodulate(obj, modulated_signal)
            output_of_BP_filter_1 = abs(conv(modulated_signal, obj.BP_filter_1,'same'));
            output_of_BP_filter_2 = abs(conv(modulated_signal, obj.BP_filter_2,'same'));
            analog_NRZ = output_of_BP_filter_1 - output_of_BP_filter_2;
            analog_NRZ = conv(analog_NRZ, obj.optional_lowpass_filter, 'same');
        end
    end    
end