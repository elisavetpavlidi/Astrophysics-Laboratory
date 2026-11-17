function  plotindices(T, DST, AL, range)
% Plot the Dst and AL indices over a selected time interval.
% Adapted from the supplied course plotting helper.

if nargin < 4
    range = [T(1) T(end)];
end

if nargin < 4
    date_format = 'dd/mm';
else
    date_format = 'dd/mm, HH:MM';
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
ind=find(T>range(1) & T<range(2));


subplot(2,1,1)
plot(T(ind), DST(ind));
set(gca,'xscale','lin','yscale','lin'); grid on;
datetick('x',date_format);
xlabel ('Time (UT)'); 
% ylim([1 10000000]);
ylabel ('Dst Index (nT)','fontsize',14,'fontweight','b');
% h=legend('Channel 1 [37.3 keV]','Channel 5 [184.9 keV]','Channel 9 [1535 keV]',0);
title('Geomagnetic Indices','fontsize',14,'fontweight','b');

subplot(2,1,2)
plot (T(ind), AL(ind) );
set(gca,'xscale','lin','yscale','lin'); grid on;
xlabel ('Time (UT)'); 
datetick('x',date_format);
% ylim([1 6]);
ylabel ('AL Index (nT)','fontsize',14,'fontweight','b');
% title('Magnetic Shell');

end
