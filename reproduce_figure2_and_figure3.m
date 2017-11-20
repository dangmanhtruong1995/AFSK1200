% Written by Dang Manh Truong (dangmanhtruong@gmail.com)
% This script reproduces Figure 2 and Figure 3 in the following paper:
% A high-performance sound-cart AX.25 Modem, by Sivan Toledo, School of
% Computer Science, Tel-Aviv University, Tel-Aviv 69978, Israel;
% stoledo@tau.ac.li 
% From the paper: 
% "I construct the filter in Matlab using the firls function,..."
% "The specification I have firls called for a complete attenuation of
% frequencies below 900Hz and above 2500Hz, with a 6dB ramp-up from 1200Hz
% to 2200Hz, with no attenuation and no gain at 2200Hz"
% Sampling frequency: Fs=11025, and the filter's order is 180,
% according to the paper
filter_order = 180;
F_s = 11025;
f_attenuated_lower = 900;
f_lower = 1200;
f_higher = 2200;
f_attenuated_higher = 2500;
b = firls(filter_order, [0 (2*f_attenuated_lower/F_s) (2*f_lower/F_s) (2*f_higher/F_s) (2*f_attenuated_higher/F_s) 1],[0 0 db2mag(-6) db2mag(0) 0 0]);
fvtool(b,1) % Figure 2
pause
filter_order = 18;
b = firls(filter_order, [0 (2*f_attenuated_lower/F_s) (2*f_lower/F_s) (2*f_higher/F_s) (2*f_attenuated_higher/F_s) 1],[0 0 db2mag(-6) db2mag(0) 0 0]);
fvtool(b,1) % Figure 3