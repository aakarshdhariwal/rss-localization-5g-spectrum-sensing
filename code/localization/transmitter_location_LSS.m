nTx=1;
nRX=4;
frequency=2e9; % frequency of operation
c=3e8; %speed of light

rss_data=rss_measurements(nTX,nRX,frequency);

% Compute distance estimates for each receiver and transmitter pair
distance_estimates = zeros(nRX, nTX);
for rx = 1:nRX
    for tx = 1:nTX
        rssi = rss_data(rx, tx);
        distance_estimates(rx, tx) = c / (4 * pi * frequency) * 10^(rssi / (10 * nTX));
    end
end

% Perform Multilateration to estimate transmitter positions
transmitter_positions = zeros(nTX, 3);  % initialize transmitter position matrix
for tx = 1:nTX
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
