function [power_time, power] = fourierPower(B_time, B, begin_time, end_time, ...
    window_size, begin_freq, end_freq)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

power_time = [];
power = [];

if isempty(begin_time) || isempty(end_time) || isempty(begin_freq) || ...
        isempty(end_freq) || isempty(window_size)
    return
end

SAMPLING_TIME = 1;

f1 = find(B_time >= begin_time, 1, 'first');
f2 = find(B_time <= end_time, 1, 'last');

series = B(f1:f2);
series_time = B_time(f1:f2);

WINDOW_SIZE = window_size;
no_of_windows = fix(length(series)/WINDOW_SIZE);

f = (1:WINDOW_SIZE/2)/(WINDOW_SIZE/2)*(1/2*SAMPLING_TIME);
f = ((0/WINDOW_SIZE):(1/WINDOW_SIZE):1/2)';
inds = [find(f >= begin_freq, 1, 'first'), find(f <= end_freq, 1, 'last')];

window_power = nan(no_of_windows, 1);
window_median_time = nan(no_of_windows, 1);

for i=1:no_of_windows
    window_indices = ((i-1)*WINDOW_SIZE + 1:i*WINDOW_SIZE)';
    
    window = series(window_indices);
    window_time = series_time(window_indices);
    
    Y = fft(window - mean(window))/WINDOW_SIZE;
    
    window_power(i) = mean((2*abs(Y(inds(1):inds(2)))).^2);
    window_median_time(i) = median(window_time);
end

power_time = window_median_time;
power = window_power;

end

