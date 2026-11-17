function plotTimeSeries(varargin)
%PLOTTIMESERIES Plot time/signal pairs with linked date axes.
% An optional final cell array supplies axis labels or units.
% A single signal is displayed across a synthetic one-day interval.
narginchk(1, Inf);
singleSeries = nargin == 1;
if singleSeries
    values = varargin{1};
    varargin = {linspace(1,2,numel(values)), values};
    units = {''};
else
    if iscell(varargin{end})
        units = varargin{end};
        varargin(end) = [];
    else
        units = repmat({''}, 1, numel(varargin)/2);
    end
end
assert(mod(numel(varargin),2) == 0, ...
    'Supply time/signal pairs and an optional cell array of labels.');
nPlots = numel(varargin)/2;
assert(numel(units) == nPlots, 'Supply one label for each signal.');
fig = gcf;
clf(fig);
set(fig,'Color','w');
ax = gobjects(nPlots,1);
for k = 1:nPlots
    X = varargin{2*k-1}(:);
    Y = varargin{2*k}(:);
    assert(numel(X) == numel(Y), 'Signal and time lengths must match.');
    validTime = isfinite(X);
    X = X(validTime);
    Y = Y(validTime);
    assert(~isempty(X), 'No finite timestamps.');
    limits = [min(X), max(X)];
    if limits(1) == limits(2)
        limits = limits + [-1 1]/86400;
    end
    finiteY = Y(isfinite(Y));
    if isempty(finiteY)
        yLimits = [-1 1];
    else
        spread = max(finiteY)-min(finiteY);
        if spread == 0
            spread = max(1,abs(finiteY(1))*0.1);
        end
        yLimits = [min(finiteY)-0.12*spread, max(finiteY)+0.12*spread];
    end
    ax(k) = subplot(nPlots,1,k,'Parent',fig);
    plot(ax(k),X,Y,'-b','LineWidth',1);
    hold(ax(k),'on');
    plot(ax(k),limits,[0 0],'-k');
    grid(ax(k),'on');
    set(ax(k),'XLim',limits,'YLim',yLimits);
    if singleSeries
        name = inputname(1);
    else
        name = inputname(2*k);
    end
    ylabel(ax(k),strtrim([name ' ' char(units{k})]));
end
linkaxes(ax,'x');
formatTimeAxes(ax);
xlabel(ax(end),'Time (UT)');
set(zoom(fig),'ActionPostCallback',@(~,~) formatTimeAxes(ax));
set(pan(fig),'ActionPostCallback',@(~,~) formatTimeAxes(ax));
end

function formatTimeAxes(ax)
for k = 1:numel(ax)
    if isgraphics(ax(k))
        set(ax(k),'XTickMode','auto');
        datetick(ax(k),'x','dd/mm HH:MM','keeplimits');
    end
end
end
