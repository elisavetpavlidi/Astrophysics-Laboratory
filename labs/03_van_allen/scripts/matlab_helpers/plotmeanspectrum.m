function  meanflux=plotmeanspectrum(T, E, I, time_range)
% Plot the mean differential electron spectrum over a strict time interval.
% Adapted from the supplied course plotting helper.

% Figure Parameters
LW=2;
MSz=18;
FSz=12;
FWt='bold';
FName='Arial';
%--------------------------------------------------------------------------
set(gcf,'color','w',...
   'defaultlinelinewidth',LW,... 
   'DefaultAxeslinewidth',LW,... 
   'DefaultTextFontName', FName,...
   'DefaultTextFontSize',FSz, ... 
   'DefaultAxesFontName', FName,...
   'DefaultAxesFontSize',FSz, ...  
   'DefaultLineMarkerSize', MSz,...
   'DefaultTextFontWeight',FWt,...
   'DefaultAxesFontWeight',FWt);
%--------------------------------------------------------------------------
ind=find(T>time_range(1) & T<time_range(2));

assert(~isempty(ind), 'No samples in the selected interval.');
meanflux = optional_nanmean(I(ind,:), 1)';


plot(E,meanflux,'.k');
set(gca,'xscale','log','yscale','log'); grid on;hold on;
xlabel ('E (keV)'); 
ylim([100 1000000]);
xlim([10 5000]);
ylabel ('I (cm^{2}\cdotsr\cdotsec\cdotkeV)^{-1}','fontsize',14,'fontweight','b');
title(['Energy Spectrum ',datestr(time_range(1)),' - ',datestr(time_range(2))]);
end
