function out = optional_nanmean(X, dim)
%OPTIONAL_NANMEAN Mean excluding NaNs, using base MATLAB.
% Compatibility helper with a primary function matching the file name.
if nargin < 2
    out = mean(X, 'omitnan');
else
    out = mean(X, dim, 'omitnan');
end
end

