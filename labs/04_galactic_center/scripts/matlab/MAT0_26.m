clear all
clf
clc

%HERE ARE THE DATA 
xo = 127.50;
yo = 126.50;

xx1 = [128.50, 129.00, 130.00, 131.25, 132.25, 133.25, 134.75, 136.50, 135.25, 134.28, 130.75, 124.25];
yy1 = [111.50, 110.75, 110.00, 110.75, 111.25, 112.75, 115.25, 117.75, 120.25, 124.25, 129.25, 122.90];

xx2 = [127.90, 129.25, 130.40, 131.40, 132.25, 133.25, 134.75, 134.90, 135.25, 134.25, 131.00, 124.25];
yy2 = [111.28, 110.75, 110.75, 110.75, 111.40, 112.90, 115.25, 117.50, 120.25, 124.25, 128.25, 122.25];

xx3 = [128.00, 128.60, 130.20, 131.35, 133.00, 134.00, 135.15, 135.25, 134.75, 134.50, 130.70, 124.45];
yy3 = [111.65, 110.85, 110.80, 110.75, 112.00, 113.70, 115.25, 118.00, 120.65, 124.25, 129.05, 122.50];

xx4 = [127.25, 128.90, 130.00, 131.20, 132.45, 133.85, 134.25, 135.35, 135.00, 134.45, 131.00, 124.35];
yy4 = [111.25, 111.25, 110.90, 111.00, 111.45, 112.90, 114.90, 117.35, 119.50, 123.60, 128.90, 122.70];

tim=[]; %e.g., tim=[2001,2002,2003]
%tim=[1992.226,1993.6,1994.321,1995.531,1996.428,1997.543,1998.365,1999.465,2000.474,2001.502,2002.252,2002.65];
tim=linspace(1992,2002,11);
tim=[tim,2002.9];

x1=0.25*(xx1+xx2+xx3+xx4)-xo;
y1=0.25*(yy1+yy2+yy3+yy4)-yo;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

No=length(tim);
set(gca,'Ydir','Reverse');

figure(1)
timq=linspace(tim(1),tim(12),100);
x1q = interp1(tim,x1,timq,"pchip");
y1q = interp1(tim,y1,timq,"pchip");
plot(tim,xx1-xo,'+b',tim,xx2-xo,'+b',tim,xx3-xo,'+b',tim,xx4-xo,'+b',tim,x1,'or');
title('check the data of xx for large discrepancies')
xlabel('time (year)')
ylabel('\Delta x')
hold on
plot(timq,x1q)
hold off

figure(2)
plot(tim,yy1-yo,'+b',tim,yy2-yo,'+b',tim,yy3-yo,'+b',tim,yy4-yo,'+b',tim,y1,'or')
title('check the data of yy for large discrepancies')
xlabel('time (year)')
ylabel('\Delta y')
hold on
plot(timq,y1q)
hold off

% THE x1,y1, and tim arrays are stored in test.mat file
DAT=[x1;y1;tim];
 save( 'DATAfile.mat', 'DAT');
 
 
 
% A = fscanf(test.mat,formatSpec)
