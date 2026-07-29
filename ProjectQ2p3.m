% =========================================================================
% Project: MATLAB Audio Signal Filtering & Noise Reduction
% Description: Applies a hybrid time-domain FIR notch filter (50-60 Hz) 
%              and frequency-domain FFT zeroing (1102 Hz & 2756 Hz) to 
%              clean noisy audio signals.
% =========================================================================

clc; clear; close all;
clc; clear; close all;

[music, fs] = audioread('music_noisy.wav');
Nsig = length(music);

disp('Playing original noisy signal...');
sound(music, fs);
pause(length(music)/fs + 1);

% Method 1: Time Domain FIR Notch Filter for 50-60 Hz hum
N = 200;       % filter order
f0 = 60;       % notch frequency in Hz
bw = 10;       % bandwidth in Hz
nyq = fs/2;

f1 = max(f0-bw/2,0)/nyq;  
f2 = min(f0+bw/2,nyq)/nyq; 

b60 = fir1(N,[f1 f2],'stop');  % create FIR bandstop filter
music_time_filtered = filter(b60,1,music);

disp('Playing music filtered for low frequency hum (time domain FIR)...');
sound(music_time_filtered, fs);
pause(length(music_time_filtered)/fs + 1);

% Method 2: Frequency Domain Notch Filter for 1102 Hz and 2756 Hz spikes
Y = fft(music);
f = (0:Nsig-1)*(fs/Nsig);

% Find frequency bins for the spikes
idx1 = find(f >= 1102-15 & f <= 1102+15);
idx2 = find(f >= 2756-15 & f <= 2756+15);

% Remove spikes by zeroing
Y(idx1) = 0;
Y(idx2) = 0;

Y(end-idx1+2) = 0;
Y(end-idx2+2) = 0;

music_freq_filtered = real(ifft(Y));

disp('Playing music filtered for high frequency spikes (frequency domain)...');
sound(music_freq_filtered, fs);
pause(length(music_freq_filtered)/fs + 1);

% Method 3: Combined Time + Frequency Filtering
% Apply time-domain FIR first
music_time_then_freq = filter(b60,1,music);

% Then apply frequency domain notch for spikes
Y_combined = fft(music_time_then_freq);
Y_combined(idx1) = 0;
Y_combined(idx2) = 0;
Y_combined(end-idx1+2) = 0;
Y_combined(end-idx2+2) = 0;

music_final_filtered = real(ifft(Y_combined));

disp('Playing fully filtered music (time + frequency domain)...');
sound(music_final_filtered, fs);
pause(length(music_final_filtered)/fs + 1);

% Time domain plots
figure;
subplot(4,1,1);
plot((0:Nsig-1)/fs, music); title('Original Noisy Music'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
subplot(4,1,2);
plot((0:Nsig-1)/fs, music_time_filtered); title('Time-Domain FIR Filtered (50-60 Hz)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
subplot(4,1,3);
plot((0:Nsig-1)/fs, music_freq_filtered); title('Frequency-Domain Filtered (1102 & 2756 Hz)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;
subplot(4,1,4);
plot((0:Nsig-1)/fs, music_final_filtered); title('Fully Filtered (Time + Frequency)'); xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Frequency  domain plots
Y_orig = abs(fft(music));
Y_time = abs(fft(music_time_filtered));
Y_freq = abs(fft(music_freq_filtered));
Y_final = abs(fft(music_final_filtered));

figure;
subplot(4,1,1);
plot(f, Y_orig); xlim([0 4000]); title('Original Spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
subplot(4,1,2);
plot(f, Y_time); xlim([0 4000]); title('Time-Domain FIR Filtered Spectrum (50-60 Hz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
subplot(4,1,3);
plot(f, Y_freq); xlim([0 4000]); title('Frequency-Domain Filtered Spectrum (1102 & 2756 Hz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
subplot(4,1,4);
plot(f, Y_final); xlim([0 4000]); title('Fully Filtered Spectrum (Time + Frequency)'); xlabel('Frequency (Hz)'); ylabel('Magnitude'); grid on;
