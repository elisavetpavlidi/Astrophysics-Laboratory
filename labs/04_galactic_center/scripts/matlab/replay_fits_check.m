% Run from the unpacked S2 analysis folder. No Curve Fitting Toolbox needed.
folder = fileparts(mfilename('fullpath'));
astrometry = load(fullfile(folder, '..', '..', 'results', 'fits_check', 'DATAfile.mat'));
orbit = load(fullfile(folder, '..', '..', 'results', 'fits_check', 'MAT_DATA_phys.mat'));
x = astrometry.DAT(1,:);
y = astrometry.DAT(2,:);
year = astrometry.DAT(3,:);
phi = deg2rad(orbit.res(1));
iota = deg2rad(orbit.res(2));
e = orbit.res(3);
p = orbit.res(4);

X = x/cos(iota);
r = hypot(X,y);
polar = atan2(y,X)-phi;
step = angle(exp(1i*diff(polar)));
step(step < -pi/2) = step(step < -pi/2)+2*pi;
theta = [polar(1), polar(1)+cumsum(step)];
J = zeros(size(theta));
for epoch = 2:numel(theta)
    J(epoch) = integral(@(psi) (1+e*cos(psi)).^(-2),theta(1),theta(epoch));
end
t = year-year(1);
massLine = polyfit(t,J,1);
secondsPerYear = 365.25*86400;
metresPerPixel = (10/22)*299792458*86400;
G = 6.67430e-11;
solarMass = 1.98847e30;
M = (p*metresPerPixel)^3*(massLine(1)/secondsPerYear)^2/G;
fprintf('Mass: %.5f million solar masses\n', M/solarMass/1e6);

radialCosine = (p./r-1)/e;
bad = abs(radialCosine)>1;
if any(bad)
    warning('Invalid radial cosines at %s',mat2str(year(bad)));
end
theta1 = rad2deg(mod(theta,2*pi));
theta2 = acos(max(-1,min(1,radialCosine)));
lowerHalf = sin(theta)<=0;
theta2(lowerHalf) = 2*pi-theta2(lowerHalf);
theta2 = rad2deg(theta2);
[kLine, fitInfo] = polyfit(theta1,theta2,1);
slopeError = fitInfo.normr/sqrt(fitInfo.df)/norm(theta1-mean(theta1));
% Central 95% Student-t multiplier via the inverse regularized beta function.
beta = betaincinv(.05,fitInfo.df/2,.5);
k95 = slopeError*sqrt(fitInfo.df*(1/beta-1));
fprintf('k %.6f +/- %.6f (95%%)\n', kLine(1), k95);
figure('Name','S2 mass and precession');
subplot(1,2,1);
plot(t,J,'o',t,polyval(massLine,t),'-');
xlabel('Years since 1992'); ylabel('J - J(1992)'); grid on;
subplot(1,2,2);
plot(theta1,theta2,'o',theta1,polyval(kLine,theta1),'-');
xlabel('theta1 (deg)'); ylabel('theta2 (deg)'); grid on;
