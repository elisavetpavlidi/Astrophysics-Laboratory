function  plotfluxesL(T, I, L, range)
% Plot orbit-segment averages in a selected Lstar range.
% Adapted from the supplied course plotting helper.

if nargin < 4
    finiteL = L(isfinite(L));
    assert(~isempty(finiteL), 'No finite Lstar values.');
    range = [min(finiteL) max(finiteL)];
end

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
ind=find(L>=range(1) & L<=range(2));
assert(~isempty(ind), 'No samples in the selected Lstar range.');

DT=1/24;
subplot(2,1,1)
[avg, avgT] = avgInSegments(I(ind,2), T(ind), DT);
plot(avgT, avg,'.-b');
set(gca,'xscale','lin','yscale','log'); grid on;
datetick('x','dd/mm');
xlabel ('Time (UT)'); 
ylim([1000 10000000]);
ylabel ('I (cm^{2}\cdotsr\cdotsec\cdotkeV)^{-1}','fontsize',14,'fontweight','b');
h=legend('Channel 2 [56.7 keV]');
title(['Diff. fluxes at L = ',num2str(range(1)),' - ',num2str(range(2))]);
yticks([1000 100000 10000000]);

subplot(2,1,2)
[avg, avgT] = avgInSegments(I(ind,9), T(ind), DT);
plot(avgT, avg,'.-m');
set(gca,'xscale','lin','yscale','log'); grid on;
datetick('x','dd/mm');
xlabel ('Time (UT)'); 
ylim([1 100000]);
ylabel ('I (cm^{2}\cdotsr\cdotsec\cdotkeV)^{-1}','fontsize',14,'fontweight','b');
h=legend('Channel 9 [1535 keV]');
title(['Diff. fluxes at L = ',num2str(range(1)),' - ',num2str(range(2))]);
yticks([1 100 10000]);


end
