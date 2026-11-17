function R = Geomagnetic_Analysis(dataDir, outputDir)
%GEOMAGNETIC_ANALYSIS Completed geomagnetic and wave analysis.
% Elisavet Pavlidi. Adapted from the completed student worksheet.
% Main-phase spectrum: 2-100 mHz; hourly Pc5 profile: 2-7 mHz.
scriptDir = fileparts(mfilename('fullpath'));
labDir = fileparts(scriptDir);
if nargin < 1 || isempty(dataDir)
    dataDir = fullfile(labDir,'data');
end
if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(labDir,'generated','matlab','geomagnetic');
end
addpath(fullfile(scriptDir,'matlab_helpers'));
assert(isfile(fullfile(dataDir,'GEOMAG.mat')), 'Missing GEOMAG.mat.');
D = load(fullfile(dataDir,'GEOMAG.mat'));
required = {'Dst_time','Dst','Bz_time','Bz','Vsw_time','Vsw', ...
    'Psw_time','Psw','Bgr_time','Bgr'};
assert(all(isfield(D,required)), 'GEOMAG.mat lacks required variables.');
assert(numel(D.Bgr_time) == numel(D.Bgr) && all(isfinite(D.Bgr)), ...
    'The magnetic-field signal must be finite and match the timestamps.');
assert(max(abs(diff(D.Bgr_time(:))*86400-1)) < 2e-5, ...
    'The Fourier calculation requires continuous one-second sampling.');
if ~isfolder(outputDir), mkdir(outputDir); end

fig = figure('Color','w','Position',[80 80 1100 500]);
plotTimeSeries(D.Dst_time,D.Dst,{'Dst (nT)'});
saveFigure(fig,fullfile(outputDir,'Dst_TimeProfile'));
fig = figure('Color','w','Position',[80 80 1100 850]);
plotTimeSeries(D.Dst_time,D.Dst,D.Bz_time,D.Bz, ...
    D.Vsw_time,D.Vsw,D.Psw_time,D.Psw, ...
    {'Dst (nT)','Bz (nT)','Vsw (km/s)','Psw (nPa)'});
saveFigure(fig,fullfile(outputDir,'Dst_and_SolarWind'));
if all(isfield(D,{'Bca_time','Bca'}))
    fig = figure('Color','w','Position',[80 80 1100 760]);
    plotTimeSeries(D.Dst_time,D.Dst,D.Bgr_time,D.Bgr, ...
        D.Bca_time,D.Bca,{'Dst (nT)','Bgr (nT)','Bca (nT)'});
    saveFigure(fig,fullfile(outputDir,'Magnetometer_Comparison'));
end

mainInterval = [datenum(2013,3,17,14,0,0),datenum(2013,3,17,15,0,0)];
spectrumBand = [0.002 0.100];
[f,a2] = fourierSpectrum(D.Bgr_time,D.Bgr, ...
    mainInterval(1),mainInterval(2),spectrumBand(1),spectrumBand(2));
sampleCount = sum(D.Bgr_time > mainInterval(1) & D.Bgr_time < mainInterval(2));
psd = a2(:)*sampleCount/2;
fig = figure('Color','w','Position',[80 80 1000 600]);
loglog(1000*f,a2,'LineWidth',1.2);
grid on;
xlim(1000*spectrumBand);
xlabel('Frequency (mHz)');
ylabel('Squared Fourier amplitude (nT^2)');
title('Main phase, 17 March 2013 14:00-15:00 UT: 2-100 mHz');
saveFigure(fig,fullfile(outputDir,'MainPhase_FourierSpectrum'));
writetable(table(f(:),a2(:),psd,'VariableNames', ...
    {'frequency_Hz','amplitude_squared_nT2','PSD_nT2_per_Hz'}), ...
    fullfile(outputDir,'MainPhase_FourierSpectrum.csv'));

profileBand = [0.002 0.007];
windowSeconds = 3600;
[tp,power] = fourierPower(D.Bgr_time,D.Bgr,datenum(2013,3,1), ...
    datenum(2013,5,1),windowSeconds,profileBand(1),profileBand(2));
fBins = (0:windowSeconds/2)'/windowSeconds;
nBins = sum(fBins >= profileBand(1) & fBins <= profileBand(2));
meanPSD = power(:)*windowSeconds/2;
integrated = power(:)*nBins/2;
fig = figure('Color','w','Position',[80 80 1100 760]);
plotTimeSeries(tp,power,D.Dst_time,D.Dst,D.Vsw_time,D.Vsw, ...
    {'Mean squared amplitude, 2-7 mHz (nT^2)','Dst (nT)','Vsw (km/s)'});
saveFigure(fig,fullfile(outputDir,'Hourly_Pc5_Profile'));
writetable(table(tp(:),power(:),meanPSD,integrated,'VariableNames', ...
    {'matlab_datenum','mean_amplitude_squared_nT2', ...
    'mean_PSD_nT2_per_Hz','integrated_power_nT2'}), ...
    fullfile(outputDir,'Hourly_Pc5_Profile.csv'));
R = struct('main_interval_UT',mainInterval,'spectrum_band_Hz',spectrumBand, ...
    'frequency_Hz',f(:),'amplitude_squared_nT2',a2(:), ...
    'window_seconds',windowSeconds,'profile_band_Hz',profileBand, ...
    'profile_time_datenum',tp(:),'mean_amplitude_squared_nT2',power(:), ...
    'mean_PSD_nT2_per_Hz',meanPSD,'integrated_power_nT2',integrated);
save(fullfile(outputDir,'Geomagnetic_Results.mat'),'R');
fprintf('Geomagnetic results saved in: %s\n',outputDir);
end

function saveFigure(fig,stem)
exportgraphics(fig,[stem '.png'],'Resolution',300);
exportgraphics(fig,[stem '.pdf'],'ContentType','vector');
savefig(fig,[stem '.fig']);
end

