% --- RSS-based Transmitter Localization Scheme for Cognitive Radio --- %

% Load data and initialize parameters
load('received_signal_data.mat');  % load received signal data
nTx = size(received_signal_data, 2);  % number of transmitters
nRx = size(received_signal_data, 1);  % number of receivers
freq = 2.4e9;  % frequency of operation
c = 3e8;  % speed of light

% Compute distance estimates for each receiver and transmitter pair
distance_estimates = zeros(nRx, nTx);
for rx = 1:nRx
    for tx = 1:nTx
        rssi = received_signal_data(rx, tx);
        distance_estimates(rx, tx) = c / (4 * pi * freq) * 10^(rssi / (10 * nTx)); %path losss function
    end
end

% Perform Multilateration to estimate transmitter positions
transmitter_positions = zeros(nTx, 3);  % initialize transmitter position matrix
for tx = 1:nTx
    % Select 3 receivers with highest RSSI for this transmitter
    [~, selected_receivers] = maxk(received_signal_data(:, tx), 3);
    % Estimate transmitter position using Multilateration
    A = [];
    b = [];
    for rx = selected_receivers'
        d = distance_estimates(rx, tx);
        xi = receiver_positions(rx, :);
        A(end+1, :) = [xi, 1];
        b(end+1, 1) = d^2 - xi*xi' ;
    end
    x = pinv(A) * b;  % Least Squares estimate of Transmitter Position
    transmitter_positions(tx, :) = x(1:3)';
end

% Plot transmitter positions
figure;
scatter3(receiver_positions(:,1), receiver_positions(:,2), receiver_positions(:,3), 'filled', 'b');
hold on;
scatter3(transmitter_positions(:,1), transmitter_positions(:,2), transmitter_positions(:,3), 'filled', 'r');
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
title('Transmitter Localization using RSS-based Scheme');
legend('Receiver Locations', 'Estimated Transmitter Locations');
