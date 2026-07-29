% =========================================================================
% Project: Design of MATLAB Audio Signal Filtering & Noise Reduction
% =========================================================================
clear; close all; clc;

fs = 8000;                         
F = [500, 1500, 2000, 3000];      % Band edges in Hz
A = [0, 1, 0];                    % Desired amplitude per band
Dev = [0.01, 0.01, 0.001];        % Ripples: stop1, pass, stop2

% Estimate order and design
[N, Fo, Ao, W] = firpmord(F, A, Dev, fs);
N=23;
h = firpm(N, Fo, Ao, W);

%  Display filter info
fprintf('Filter order N = %d\n', N);
fprintf('Filter length = %d\n', length(h));
fprintf('Number of coefficients = %d\n\n', length(h));

% Display all coefficients in table
fprintf('FILTER COEFFICIENTS\n');
fprintf('n\t\th[n]\n');
fprintf('--------------------\n');
for n = 1:length(h)
    fprintf('%2d\t% .6f\n', n-1, h(n));
end
fprintf('\n');

%  Plot frequency response
figure;
freqz(h, 1, 1024, fs);
title('Bandpass FIR Filter Magnitude and Phase Responses');

% Verification
[H, f] = freqz(h, 1, 4096, fs);
H_db = 20*log10(abs(H));

% Stopband 1
stop1_max_db = max(H_db(f <= 500));
stop1_max_linear = 10^(stop1_max_db/20);

% Passband
H_pass = abs(H(f >= 1500 & f <= 2000));
passband_ripple = max(H_pass) - min(H_pass);

% Stopband 2
stop2_max_db = max(H_db(f >= 3000));
stop2_max_linear = 10^(stop2_max_db/20);

% Display verification
fprintf('    VERIFICATION RESULTS \n');
fprintf('Stopband 1 (0-500 Hz):\n');
fprintf('  Max magnitude: %.2f dB (%.6f linear)\n', stop1_max_db, stop1_max_linear);
if stop1_max_linear <= 0.01
    fprintf('  Spec: ≤ 0.01 linear (≤ -40 dB) PASS\n\n');
else
    fprintf('  Spec: ≤ 0.01 linear (≤ -40 dB) FAIL\n\n');
end

fprintf('Passband (1500-2000 Hz):\n');
fprintf('  Ripple: %.6f linear\n', passband_ripple);
if passband_ripple <= 0.01
    fprintf('  Spec: ≤ 0.01 linear PASS\n\n');
else
    fprintf('  Spec: ≤ 0.01 linear FAIL\n\n');
end

fprintf('Stopband 2 (3000-4000 Hz):\n');
fprintf('  Max magnitude: %.2f dB (%.6f linear)\n', stop2_max_db, stop2_max_linear);
if stop2_max_linear <= 0.001
    fprintf('  Spec: ≤ 0.001 linear (≤ -60 dB) PASS\n');
else
    fprintf('  Spec: ≤ 0.001 linear (≤ -60 dB) FAIL\n');
end