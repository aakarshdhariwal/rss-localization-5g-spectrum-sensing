% Parameters to be changed and to be looked out for are step_size and cols (which is the number of iterations);
% Look out for how the RSS measurements are calculated based on the
% function chosen from rss_measurements or calculate_rss. 

clc;
close all;
clear all; 

%% RX calculation

% Define the size of the grid
clc;
clear all;
%area_local = [];
%for l=1:4
gridSize = [100, 100];
Len = gridSize(1,1);
Breadth = gridSize(1,2);
% Define the number of total sensors
numSensors = [4,9,16,25,36,49];



% Tx parameters
pu_x = 18; %floor(random('Uniform',0,gridSize(1)));
pu_y = 37; %floor(random('Uniform',0,gridSize(1)));
tx_positions = [pu_x, pu_y];

% Define true transmitter power and path loss exponent
tx_power = -10;    % in dB
Numberofexps = 25;
theta_samples = [];


for k = 1:size(numSensors,2)

% Initialize the grid with zeros
%grid = zeros(gridSize);


grid_size = ceil(sqrt(numSensors(k)));
 
%Calculate the spacing between sensors in each dimension
spacing_x = floor(Len / (grid_size - 1));
spacing_y = floor(Breadth / (grid_size - 1));
% spacingX = round(gridSize(1) / (numSensorsX +1));
% spacingY = round(gridSize(2) / (numSensorsY +1));
 
%Generate the coordinates for the remaining sensors using meshgrid
start_point = randi(1, [1,2]);
x_coords = floor(linspace(start_point(1,1), start_point(1,1) + (grid_size - 1) * spacing_x, grid_size));
y_coords = floor(linspace(start_point(1,2), start_point(1,2) + (grid_size - 1) * spacing_y, grid_size));
[x,y] = meshgrid(x_coords,y_coords);
rx = [x(:),y(:)];



%[X, Y] = meshgrid(spacingX:spacingX:gridSize(1)-spacingX, spacingY:spacingY:gridSize(2)-spacingY);
 

% Calculate true distances (euclidean distance) between transmitters and receivers
d_true = pdist2(rx, tx_positions);
path_loss_exp = 3.5;
d_0 = 2;
% Generating Received Signal Strength levels

rss_true = rss_measurements(tx_power,rx,path_loss_exp,d_0,d_true);
%rss_true = rss_measurements_ofdm(ofdm_tx_signal,ofdm_parameters,path_loss_exp,d_0,d_true);
%rss_true = calculate_rss(ofdm_tx_signal,rx,path_loss_exp,d_0,d_true);

% Calculating estimated Tx positions
theta_samples(:,k) = calculate_tx_pos(rx,rss_true,Numberofexps,path_loss_exp);

end


%% Plot Localization Error in meters
% mse_error =(1/size(mse_error,2))*mse_error;
%mse_error_log = 10*log10(mse_error);
tx_pos = tx_positions';
localisation_error = zeros(1,size(theta_samples,2));

for k = 1: size(theta_iterations,2)

    localisation_error(1,k) = sqrt(((tx_pos(1,1) - theta_samples(1,k))^2 + (tx_pos(2,1) - theta_samples(2,k))^2));

end

%% Plot Number 1
x_axis = 0:cols-1;
figure;
plot(x_axis,mse_error_log);
xlabel('Number of Iterations');
ylabel('MSE Error [dB]');
title(' MSE Error for TX at position')

%% Plot number 2 for tranmistter location convergence
tx_x = tx_positions(1,1)*ones(1,cols);
tx_y = tx_positions(1,2)*ones(1,cols);
figure;
plot(1:cols,tx_x(1,:),'r');
hold on 
plot(tx_y(1,:),'b');
plot(1:cols,theta_iterations(1,:),'LineWidth',1.5,'Color','r');
plot(1:cols, theta_iterations(2,:),'LineWidth',1.5,'Color','b');
hold off
xlabel('Number of iterations');
ylabel('Trnsmitter Locations (x,y)');
legend('X Cord','Y Cord', 'Estimated X','Estimated Y');
title('Estimated Transmitter Location vs True TRX values');

%% Plot number 3 for localisations error

figure;
plot(1:cols,(1/size(localisation_error,2))*localisation_error);
xlabel('Number of iterations');
ylabel('Localisation Errors');
%legend('X Cord','Y Cord', 'Estimated X','Estimated Y')
title('Localisation Errors');

%% Scatter plot for the transmitter location estimation

% Display the estimated transmitter location and optimization details
fprintf('Estimated transmitter location: (%f, %f)\n', theta(1), theta(2));
% fprintf('Number of function evaluations: %d\n', output.funcCount);
% fprintf('Number of iterations: %d\n', output.iterations);

% Plot the true and estimated transmitter locations and the RSS values
figure;
scatter(rx_positions(:,1),rx_positions(:,2),'filled','b');
hold on
scatter(tx_positions(:,1), tx_positions(:,2), 'filled', 'r');
scatter(theta(1), theta(2), 'filled', 'g');
hold off
legend('Receiver', 'True Transmitter', 'Estimated Transmitter');
xlabel('x (m)');
ylabel('y (m)');
title('Active Transmitter Location Estimation');


%% Function to calculate the theta parameter.

function theta_samples = calculate_tx_pos(rx,rss_true,Numberofexps,path_loss_exp)



% Select 4 receivers with highest RSSI for this transmitter
tx_power = -10;
d_0 =2;
[selected_receivers, indices] = maxk(rss_true, 4);
rss = selected_receivers;
%indices = randperm(numel(rss_true),4)';
%rss = rss_true(indices);
%rx_positions = [rx_positions(1,1), rx_positions(1,2); rx_positions(1,1),rx_positions(end,2); rx_positions(end,1) rx_positions(1,1); rx_positions(end,1), rx_positions(end,2)];

A=[];
b=[];
%generating A
for i=1:size(indices,1)-1

    A(i,:) =  [2*(rx(indices(i+1),1) - rx(indices(1),1)), 2*(rx(indices(...
        i+1),2) - rx(indices(1),2)), 10^(-rss(i+1)/(5*path_loss_exp)) - 10^(-rss(1)/(5*path_loss_exp))  ];

end

%generate b

for n = 1:size(indices,1)-1

    b(n,:) = rx(indices(n+1),1)^2 + rx(indices(n+1),2)^2 - rx(indices(1),2)^2 - rx(indices(1),2)^2;

end

tx_path_loss_exp=(d_0^2)*10^(tx_power/(5*path_loss_exp));
theta = zeros(3,1);
%theta = [rx(indices(1),1);rx(indices(1),2);tx_path_loss_exp];
cols = 5e5;
mse_error = zeros(1,cols);
step_size = 1e-8;
%[theta_iterations, mse_error] = mysteepest(A, b, theta, 10^-5, cols);
for num = 1:cols

    error = b - A*theta;
    %delta = error'*error;
    temp = A'*error;
    %alpha = (delta)/((temp'*error)+1e-4);
    theta = theta + step_size*A'*error;
    %theta = theta + alpha*error;
    %theta_iterations = [theta_iterations, theta];
    mse_error(1,num) = (b-A*theta)'*(b-A*theta);
   
end
theta_samples = theta;
end


