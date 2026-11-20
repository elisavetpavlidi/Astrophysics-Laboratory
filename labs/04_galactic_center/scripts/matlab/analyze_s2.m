function analyze_s2()
% Recompute the reported S2 astrometry, trial fits and mass from the tables.
% The final regression printed here is a check on the rounded table inputs.
root = fullfile(fileparts(mfilename('fullpath')), '..', '..');
measurements = readtable(fullfile(root, 'data', 'astrometry.csv'));
trials = readtable(fullfile(root, 'results', 'mat2_trials.csv'));
year = measurements.year;
x = mean(measurements{:, 2:2:8}, 2);
y = mean(measurements{:, 3:2:9}, 2);

% MAT2 used angle grid points spaced by 180/131 and 90/131 degrees.
phi = deg2rad(round(trials.phi_deg*131/180)*180/131);
iota = deg2rad(round(trials.inclination_deg*131/90)*90/131);
for j = 1:height(trials)
    X = (x-trials.x0_px(j))/cos(iota(j));
    Y = y-trials.y0_px(j);
    [theta, r] = cart2pol(X,Y);
    theta = theta-phi(j);
    [line, halfWidth] = linear_fit(cos(theta),1./r);
    p = 1/line(2);
    e = line(1)*p;
    score = abs(line(1)/halfWidth);
    fprintf('MAT2 trial %d: p = %.5f px, e = %.5f, linearity = %.4f\n',j,p,e,score);
    if j == 1
        selected = struct('theta',theta,'r',r,'p',p,'e',e);
    end
end

% MAT3 mass from the slope of J(theta) against time.
theta = selected.theta;
e = selected.e;
p = selected.p;
step = angle(exp(1i*diff(theta)));
largeNegative = step < -pi/2;
massStep = step;
massStep(largeNegative) = massStep(largeNegative)+2*pi;
massAngle = [theta(1); theta(1)+cumsum(massStep)];
J = arrayfun(@(q) integral(@(z) (1+e*cos(z)).^(-2),massAngle(1),q),massAngle);
coeff = polyfit(year-year(1),J,1);
metresPerPixel = (10/22)*299792458*86400;
G = 6.67e-11;
M = (p*metresPerPixel)^3*(coeff(1)/(365.25*86400))^2/G;
fprintf('MAT3 mass = %.4f million solar masses\n',M/(2e30*1e6));

% MAT4 check with the published table, using the teaching-code branch rule.
thetaStep = step;
thetaStep(largeNegative) = -(2*pi-abs(thetaStep(largeNegative)));
theta1 = mod([theta(1); theta(1)+cumsum(thetaStep)],2*pi);
radialCosine = (p./selected.r-1)/e;
assert(all(abs(radialCosine)<=1),'Radial cosine fell outside the physical interval.');
theta2 = acos(radialCosine);
lower = sin(theta)<=0;
theta2(lower) = 2*pi-theta2(lower);
[line,halfWidth] = linear_fit(theta1,theta2);
fprintf('MAT4 check on table input = %.5f +/- %.5f (95%%)\n',line(1),halfWidth);
fprintf('Recorded MATLAB Online result = 0.84756 +/- 0.17692 (see report)\n');
end

function [line, halfWidth] = linear_fit(x,y)
[line,fit] = polyfit(x,y,1);
beta = betaincinv(.05,fit.df/2,.5);
criticalValue = sqrt(fit.df*(1/beta-1));
halfWidth = criticalValue*fit.normr/(sqrt(fit.df)*norm(x-mean(x)));
end
