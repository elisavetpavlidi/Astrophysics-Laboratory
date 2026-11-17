function [e, stats] = fitPowerLaw(T, E, I, time_range, energy_channels)
%FITPOWERLAW Fit mean flux as A * E^(-gamma) by OLS in log10 space.
% Adapted from the supplied completed helper. E is in keV.
% e = [A, gamma]. Optional stats includes the log-space R-squared.
T = T(:);
E = E(:);
assert(size(I,1) == numel(T) && size(I,2) == numel(E), ...
    'Flux dimensions must match the time and energy vectors.');
assert(numel(time_range) == 2 && time_range(1) < time_range(2), ...
    'Supply an increasing two-element time interval.');
assert(numel(energy_channels) == 2 && ...
    all(energy_channels == fix(energy_channels)) && ...
    energy_channels(1) >= 1 && ...
    energy_channels(2) >= energy_channels(1) && ...
    energy_channels(2) <= numel(E), 'Invalid channel bounds.');
ind = find(T > time_range(1) & T < time_range(2));
assert(~isempty(ind), 'No samples in the selected interval.');
meanflux = optional_nanmean(I(ind,:), 1)';
channels = energy_channels(1):energy_channels(2);
energies = E(channels);
fluxes = meanflux(channels);
assert(numel(channels) >= 2 && ...
    all(isfinite(energies) & energies > 0) && ...
    all(isfinite(fluxes) & fluxes > 0), ...
    'The logarithmic fit requires positive finite energies and fluxes.');
xx = log10(energies);
yy = log10(fluxes);
P = polyfit(xx, yy, 1);
e = [10.^P(2), -P(1)];
residual = yy - polyval(P, xx);
denominator = sum((yy - mean(yy)).^2);
stats = struct('sample_count',numel(ind),'channels',channels, ...
    'mean_flux',meanflux,'gamma',e(2),'r_squared',NaN);
if denominator > 0
    stats.r_squared = 1 - sum(residual.^2)/denominator;
end
if isequal(energy_channels(:)', [1 6])
    E1 = 30:230;
elseif isequal(energy_channels(:)', [7 10])
    E1 = 570:2200;
else
    E1 = logspace(log10(min(energies)), log10(max(energies)), 200);
end
hold on;
plot(E1, e(1).*E1.^(-e(2)), '-g', 'LineWidth',1.5);
end
