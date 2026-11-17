function [avg, avgT] = avgInSegments(x, t, DT)
%AVGINSEGMENTS Average samples separated by gaps greater than DT.
% Adapted from the course helper; a continuous input forms one segment.
x = x(:);
t = t(:);
assert(numel(x) == numel(t), 'Signal and time lengths must match.');
if isempty(x)
    avg = [];
    avgT = [];
    return;
end
assert(all(isfinite(t)) && all(diff(t) >= 0), ...
    'Times must be finite and ordered.');
if nargin < 3 || isempty(DT)
    if numel(t) == 1
        DT = Inf;
    else
        DT = mode(diff(t));
    end
end
assert(isscalar(DT) && DT >= 0, 'DT must be a nonnegative scalar.');
edges = [0; find(diff(t) > DT); numel(t)];
avg = nan(numel(edges)-1, 1);
avgT = nan(size(avg));
for k = 1:numel(avg)
    indices = edges(k)+1:edges(k+1);
    avg(k) = optional_nanmean(x(indices), 1);
    avgT(k) = median(t(indices));
end
end
