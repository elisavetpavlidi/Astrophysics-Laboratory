function  plotfluxes(T, MLT, Lstar, I, range)
% Plot channels 2 and 9 together with Lstar and magnetic local time.
% Adapted from the supplied course plotting helper.

if nargin < 5
    range = [T(1) T(end)];
end

if nargin < 5
    date_format = 'dd/mm';
else
    date_format = 'dd/mm HH:MM';
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


subplot(3,1,1)
plot(T(ind), I(ind,2),'-b', T(ind), I(ind,9),'-m');
set(gca,'xscale','lin','yscale','log'); grid on;
datetick('x',date_format);
xlabel ('Time (UT)'); 
ylim([1 10000000]);
ylabel ('I (cm^{2}\cdotsr\cdotsec\cdotkeV)^{-1}','fontsize',14,'fontweight','b');
h=legend('Channel 2 [56.7 keV]','Channel 9 [1535 keV]');
title(['Diff. fluxes ',datestr(range(1)),' - ',datestr(range(2))]);

subplot(3,1,2)
plot (T(ind), Lstar(ind),'-k' );
set(gca,'xscale','lin','yscale','lin'); grid on;
xlabel ('Time (UT)'); 
datetick('x',date_format);
ylim([1 6]);
ylabel ('L^{*}','fontsize',14,'fontweight','b');
title('Magnetic Shell');

subplot(3,1,3)
plot (T(ind), MLT(ind) ,'-k');
set(gca,'xscale','lin','yscale','lin'); grid on;
xlabel ('Time (UT)'); 
datetick('x',date_format);
ylim([0 25]);
ylabel ('MLT (hours)','fontsize',14,'fontweight','b');
title('Magnetic Local Time');
end
