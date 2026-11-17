function R = ElectronSpectrum_Analysis(dataDir, outputDir)
%ELECTRONSPECTRUM_ANALYSIS Completed electron analysis for the final report.
% Elisavet Pavlidi. Adapted from the completed student MATLAB worksheet.
% Primary intervals: Pre14, Main and Recovery; Pre12 checks the start time.
% Usage: R = ElectronSpectrum_Analysis(dataDir, outputDir).
scriptDir = fileparts(mfilename('fullpath'));
labDir = fileparts(scriptDir);
if nargin < 1 || isempty(dataDir)
    dataDir = fullfile(labDir,'data');
end
if nargin < 2 || isempty(outputDir)
    outputDir = fullfile(labDir,'generated','matlab','electrons');
end
addpath(fullfile(scriptDir,'matlab_helpers'));
assert(isfile(fullfile(dataDir,'RBSP.mat')), 'Missing RBSP.mat.');
assert(isfile(fullfile(dataDir,'RBSPenergy.mat')), 'Missing RBSPenergy.mat.');
D = load(fullfile(dataDir,'RBSP.mat'));
energy = load(fullfile(dataDir,'RBSPenergy.mat'));
assert(all(isfield(D,{'T','CountRate','MLT','Lstar'})), ...
    'RBSP.mat must contain T, CountRate, MLT and Lstar.');
assert(all(isfield(energy,{'E','Emin','Emax','G'})), ...
    'RBSPenergy.mat must contain E, Emin, Emax and G.');
T = D.T(:);
E = energy.E(:);
DE = energy.Emax(:)-energy.Emin(:);
G = energy.G(:);
assert(size(D.CountRate,1) == numel(T) && ...
    size(D.CountRate,2) == numel(E) && numel(E) == 10, ...
    'The analysis expects ten energy channels and matching timestamps.');
assert(all(DE > 0 & G > 0), 'Energy widths and geometric factors must be positive.');
I = bsxfun(@rdivide,D.CountRate,(DE.*G)');
if ~isfolder(outputDir), mkdir(outputDir); end

fig = figure('Color','w','Position',[80 80 1100 760]);
plotfluxes(T,D.MLT,D.Lstar,I,[datenum(2013,3,16),datenum(2013,3,21)]);
saveFigure(fig,fullfile(outputDir,'Flux_Profile'));
fig = figure('Color','w','Position',[80 80 1100 650]);
plotfluxesL(T,I,D.Lstar,[4 5]);
saveFigure(fig,fullfile(outputDir,'Flux_At_Lstar_4to5'));

caseNames = {'Pre14','Main','Recovery','Pre12'};
caseTimes = [datenum(2013,3,16,14,0,0), datenum(2013,3,17,0,0,0); ...
             datenum(2013,3,17,13,0,0), datenum(2013,3,17,15,0,0); ...
             datenum(2013,3,18,16,0,0), datenum(2013,3,18,20,0,0); ...
             datenum(2013,3,16,12,0,0), datenum(2013,3,17,0,0,0)];
parameters = nan(numel(caseNames),4);
rSquared = nan(numel(caseNames),2);
R = struct();
R.flux_units = 'cm^-2 sr^-1 s^-1 keV^-1';
R.fit_convention = 'Unweighted OLS of log10(mean flux) against log10(E in keV).';
R.shared_Lstar_range = [5.1 5.5];
for k = 1:numel(caseNames)
    fig = figure('Color','w','Position',[80 80 1000 650]);
    meanFlux = plotmeanspectrum(T,E,I,caseTimes(k,:));
    [low,lowStats] = fitPowerLaw(T,E,I,caseTimes(k,:),[1 6]);
    [high,highStats] = fitPowerLaw(T,E,I,caseTimes(k,:),[7 10]);
    parameters(k,:) = [low high];
    rSquared(k,:) = [lowStats.r_squared highStats.r_squared];
    selected = T > caseTimes(k,1) & T < caseTimes(k,2);
    shared = selected & D.Lstar(:) >= 5.1 & D.Lstar(:) <= 5.5;
    R.cases(k).phase = caseNames{k};
    R.cases(k).time_interval_UT = caseTimes(k,:);
    R.cases(k).sample_count = sum(selected);
    R.cases(k).mean_flux = meanFlux;
    R.cases(k).low_energy_fit = low;
    R.cases(k).high_energy_fit = high;
    R.cases(k).r_squared = rSquared(k,:);
    R.cases(k).shared_Lstar_samples = sum(shared);
    R.cases(k).shared_Lstar_mean_flux = optional_nanmean(I(shared,:),1)';
    writetable(table(E,meanFlux,'VariableNames', ...
        {'energy_keV','mean_differential_flux'}), ...
        fullfile(outputDir,['electron_' caseNames{k} '.csv']));
    saveFigure(fig,fullfile(outputDir,['Spectrum_' caseNames{k}]));
end
fitTable = table(caseNames(:),parameters(:,1),parameters(:,2), ...
    parameters(:,3),parameters(:,4),rSquared(:,1),rSquared(:,2), ...
    'VariableNames',{'phase','A_channels_1to6','gamma_channels_1to6', ...
    'A_channels_7to10','gamma_channels_7to10','R2_channels_1to6', ...
    'R2_channels_7to10'});
R.fit_parameters = fitTable;
writetable(fitTable,fullfile(outputDir,'electron_fit_parameters.csv'));
save(fullfile(outputDir,'ElectronSpectrum_Results.mat'),'R');
fprintf('Electron results saved in: %s\n',outputDir);
end

function saveFigure(fig,stem)
exportgraphics(fig,[stem '.png'],'Resolution',300);
exportgraphics(fig,[stem '.pdf'],'ContentType','vector');
savefig(fig,[stem '.fig']);
end

