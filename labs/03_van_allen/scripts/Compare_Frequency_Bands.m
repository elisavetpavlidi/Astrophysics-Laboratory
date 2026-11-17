%% Compare_Frequency_Bands.m
% Elisavet Pavlidi - Van Allen laboratory
% Controlled comparison of 2-7 and 2-100 mHz using the ORIGINAL lab helpers.
% Required in the current folder / MATLAB path:
%   GEOMAG.mat, fourierSpectrum.m, fourierPower.m
% The accompanying Python script executed a faithful numerical port of the
% uploaded helpers on the supplied .mat files. This MATLAB driver is also
% provided for native reproduction; no MATLAB runtime was available here.
%
% Keep the same helper implementation, normalization and time interval for
% both bands. Do not call the 2-100 mHz result 'Pc5 power': it includes Pc4/3.
% Mean spectral power and integrated band power are different quantities.
% A wider band need NOT have a larger band-AVERAGED value.
% Verified helper output: mean squared Fourier amplitude in nT^2.
% For a window of N one-second samples, mean PSD = (N/2)*mean amplitude^2;
% integrated band power = (number of bins/2)*mean amplitude^2.
% These relations hold for the selected positive, non-Nyquist frequencies.

clearvars; close all; clc;
if isfolder('matlab_helpers'), addpath('matlab_helpers'); end
assert(isfile('GEOMAG.mat'), 'Place GEOMAG.mat in the current folder.');
assert(exist('fourierSpectrum','file') == 2, 'Missing fourierSpectrum.m');
assert(exist('fourierPower','file') == 2, 'Missing fourierPower.m');
D = load('GEOMAG.mat');
assert(all(isfield(D, {'Bgr_time','Bgr','Dst_time','Dst'})), ...
    'GEOMAG.mat must contain Bgr_time, Bgr, Dst_time and Dst.');
outDir = 'frequency_band_comparison';
if ~isfolder(outDir), mkdir(outDir); end
bands = [0.002 0.007; 0.002 0.100];
bandNames = {'Pc5: 2-7 mHz','Pc5 + Pc4 + Pc3: 2-100 mHz'};
bandTags = {'2to7mHz','2to100mHz'};
col = [0.10 0.28 0.72; 0.76 0.23 0.14];
R = struct();
R.bands_Hz = bands;
R.normalization = 'Original helpers: mean squared Fourier amplitude in nT^2; 1 s sampling.';

%% 1. FFT: two bands for each of three equal-duration time intervals.
% One hour in each phase avoids changing spectral resolution between phases.
% Main-phase interval is the one selected in the uploaded driver.
caseNames = {'PreStorm','MainPhase','RecoveryPhase'};
caseTimes = [datenum(2013,3,16,14,0,0), datenum(2013,3,16,15,0,0); ...
             datenum(2013,3,17,14,0,0), datenum(2013,3,17,15,0,0); ...
             datenum(2013,3,18,18,0,0), datenum(2013,3,18,19,0,0)];
for k = 1:numel(caseNames)
    fig = figure('Color','w','Position',[80 80 1100 650]);
    for b = 1:2
        [f, p] = fourierSpectrum(D.Bgr_time, D.Bgr, ...
            caseTimes(k,1), caseTimes(k,2), bands(b,1), bands(b,2));
        assert(numel(f) == numel(p), 'Frequency/power vector size mismatch.');
        R.spectra(k,b).phase = caseNames{k};
        R.spectra(k,b).time_interval = caseTimes(k,:);
        R.spectra(k,b).frequency_Hz = f(:);
        R.spectra(k,b).power = p(:);
        subplot(2,1,b);
        loglog(1000*f, p, 'Color',col(b,:), 'LineWidth',1.2);
        xlim(1000*bands(b,:)); grid on;
        xlabel('Frequency (mHz)');
        ylabel('Squared Fourier amplitude (nT^2)');
        title(sprintf('%s | %s to %s UT', bandNames{b}, ...
            datestr(caseTimes(k,1),'dd-mmm-yyyy HH:MM'), ...
            datestr(caseTimes(k,2),'dd-mmm-yyyy HH:MM')));
        csvName = fullfile(outDir, sprintf('FFT_%s_%s.csv',caseNames{k},bandTags{b}));
        writetable(table(f(:),p(:),'VariableNames',{'frequency_Hz','power'}),csvName);
    end
    saveFigure(fig, fullfile(outDir,['FFT_' caseNames{k} '_comparison']));
end

%% 2. Mean Fourier power: same band comparison for both window lengths.
% The primary comparison uses 3600 s, as requested in the assignment.
% The 1000 s case preserves the setting tried in the uploaded driver.
windowSeconds = [3600 1000];
tBegin = datenum(2013,3,1,0,0,0);
tEnd = datenum(2013,5,1,0,0,0);
for w = 1:numel(windowSeconds)
    for b = 1:2
        [tp, pp] = fourierPower(D.Bgr_time,D.Bgr,tBegin,tEnd, ...
            windowSeconds(w),bands(b,1),bands(b,2));
        R.profiles(w,b).window_seconds = windowSeconds(w);
        R.profiles(w,b).time_datenum = tp(:);
        R.profiles(w,b).mean_power = pp(:);
        fBins = (0:windowSeconds(w)/2)'/windowSeconds(w);
        nBins = sum(fBins >= bands(b,1) & fBins <= bands(b,2));
        R.profiles(w,b).mean_PSD = pp(:)*windowSeconds(w)/2;
        R.profiles(w,b).band_power = pp(:)*nBins/2;
        outTable = table(datetime(tp(:),'ConvertFrom','datenum'),pp(:), ...
            R.profiles(w,b).mean_PSD,R.profiles(w,b).band_power, ...
            'VariableNames',{'time_UT','mean_amplitude_squared_nT2', ...
            'mean_PSD_nT2_per_Hz','integrated_power_nT2'});
        writetable(outTable,fullfile(outDir,sprintf('Power_%ds_%s.csv', ...
            windowSeconds(w),bandTags{b})));
    end
end

%% 3. Storm detail: both frequency bands at identical time resolution + Dst.
stormLimits = [datenum(2013,3,16), datenum(2013,3,21)];
fig = figure('Color','w','Position',[80 80 1150 820]);
ax = gobjects(3,1);
for w = 1:2
    ax(w) = subplot(3,1,w); hold on;
    for b = 1:2
        plot(R.profiles(w,b).time_datenum, R.profiles(w,b).mean_power, ...
            'Color',col(b,:), 'LineWidth',1.1);
    end
    xlim(stormLimits); grid on;
    datetick('x','dd/mm HH:MM','keeplimits','keepticks');
    ylabel('Mean squared amplitude (nT^2)');
    title(sprintf('Window = %d s',windowSeconds(w)));
    legend(bandNames,'Location','best');
end
ax(3) = subplot(3,1,3);
plot(D.Dst_time,D.Dst,'k','LineWidth',1.1); grid on; xlim(stormLimits);
datetick('x','dd/mm HH:MM','keeplimits','keepticks');
ylabel('Dst (nT)'); xlabel('Time (UT)');
linkaxes(ax,'x');
saveFigure(fig,fullfile(outDir,'Storm_BothBands_BothWindows_Dst'));

%% 4. Full March-April overview, same bands and windows.
fig = figure('Color','w','Position',[80 80 1150 820]);
ax = gobjects(3,1);
for w = 1:2
    ax(w) = subplot(3,1,w); hold on;
    for b = 1:2
        plot(R.profiles(w,b).time_datenum,R.profiles(w,b).mean_power, ...
            'Color',col(b,:),'LineWidth',0.8);
    end
    xlim([tBegin tEnd]); grid on;
    datetick('x','dd-mmm','keeplimits','keepticks');
    ylabel('Mean squared amplitude (nT^2)');
    title(sprintf('Window = %d s',windowSeconds(w)));
    legend(bandNames,'Location','best');
end
ax(3) = subplot(3,1,3);
plot(D.Dst_time,D.Dst,'k'); grid on; xlim([tBegin tEnd]);
datetick('x','dd-mmm','keeplimits','keepticks');
ylabel('Dst (nT)'); xlabel('Time (UT)'); linkaxes(ax,'x');
saveFigure(fig,fullfile(outDir,'MarchApril_BothBands_BothWindows_Dst'));
save(fullfile(outDir,'Frequency_Band_Comparison_Results.mat'),'R');
fprintf('Results saved in: %s\n',fullfile(pwd,outDir));

function saveFigure(fig,stem)
    exportgraphics(fig,[stem '.png'],'Resolution',300);
    exportgraphics(fig,[stem '.pdf'],'ContentType','vector');
    savefig(fig,[stem '.fig']);
end
