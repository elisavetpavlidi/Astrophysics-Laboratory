function [Freq, FftPower] = fourierSpectrum(Bgr_time, Bfilt, begin_time, end_time, ...
     begin_freq, end_freq)
 
% get temporal indices
ind1 = find(Bgr_time > begin_time, 1, 'first');
ind2 = find(Bgr_time < end_time, 1, 'last');

X = Bfilt(ind1:ind2);
L = length(X);
Y = fft(X);
F = (0:1/L:1/2)';

find1 = find(F >= begin_freq, 1, 'first');
find2 = find(F <= end_freq, 1, 'last');

Freq = F(find1:find2);
FftPower = (2*abs(Y(find1:find2))/L).^2;

% figure;
% plot(Freq, FftPower);
% xlabel('Freq (Hz)')
% ylabel('Fourier Power (nT^2)');

end

