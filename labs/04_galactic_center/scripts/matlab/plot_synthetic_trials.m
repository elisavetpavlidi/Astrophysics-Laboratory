function plot_synthetic_trials()
% Visualize the six synthetic MAT1 inputs using reproducible noise draws.
% The recorded MAT1 fits are included as separate rows in the same CSV.
root = fullfile(fileparts(mfilename('fullpath')), '..', '..');
trials = readtable(fullfile(root, 'results', 'mat1_trials.csv'));
trials = trials(strcmp(trials.sample,'input'),:);
rng(26,'twister');
figure('Name','Synthetic S2 projection trials');
tiledlayout(2,3);
for j = 1:height(trials)
    theta = linspace(0,2*pi,trials.N(j));
    radius = trials.p(j)./(1+trials.e(j)*cos(theta));
    phi = deg2rad(trials.phi_deg(j));
    iota = deg2rad(trials.inclination_deg(j));
    projected = [cos(iota)*radius.*cos(theta+phi); radius.*sin(theta+phi)];
    measured = projected.*(1+trials.fractional_noise(j)*randn(size(projected)));
    nexttile;
    plot(projected(1,:),projected(2,:),'-',measured(1,:),measured(2,:),'.');
    axis equal;
    title(sprintf('Trial %d, noise %.0f%%',trials.trial(j),100*trials.fractional_noise(j)));
end
end
