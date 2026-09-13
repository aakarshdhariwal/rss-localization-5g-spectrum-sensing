%% The following code generates LIvE Algorithm where the RSS measurements are generated using two functions
% First using the rss_measurements: where the rss measurements are
% averaged out and are based on formulations from the Optimised paper (base
% paper). Seond method is the calculate_rss file where the measurements are
% generated using the normrnd function. The parameters to look out for are
% the min_no_sensors that are used to calculate the constraints in matrix A
% and b to start the optimization problem. The cost functions are defined
% in the last part of the code.

%% selecting sensors and defining grid in another manner

% edge_width = 100;  %meters
% edge_height = 100; %meters
% 
% num_of_sensors_d = 6;
% num_of_sensors = num_of_sensors_d.^2;
% 
% %num_of_regions = num_of_sensors;
% 
% num_grid_x = 100;
% num_grid_y = 100;
% 
% %primary trx locations
% pu_x = 62; %random('Uniform',0,edge_width);
% pu_y = 47; %random('Uniform',0,edge_height);
% 
% 
% %[XSens, YSens] = meshgrid((0.5*edge_width/num_of_sensors_d):edge_width/num_of_sensors_d:edge_width, (0.5*edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);
% [XSens, YSens] = meshgrid((edge_width/num_of_sensors_d):edge_width/num_of_sensors_d:edge_width, (edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);
% 
% rx = [XSens(:),YSens(:)];
% sensor_dist_arr = ((XSens - pu_x).^2 + (YSens - pu_y).^2).^0.5;
% 
% [XGrid,YGrid] = meshgrid((0.5*edge_width/num_grid_x):edge_width/num_grid_x:edge_width, (0.5*edge_height/num_grid_y):edge_height/num_grid_y:edge_height);
% grid_dist_arr = ((XGrid - pu_x).^2 + (YGrid - pu_y).^2).^0.5;
% 
% corner = [XSens(1,1),YSens(1,1);XSens(1,end),YSens(1,1);XSens(1,1),YSens(end,1);XSens(1,end),YSens(end,1)];
% temp = ismember(rx,corner,'rows');
% ind = find(temp);
% remaining_sensors = find(temp==0);
% remaining_index = [ind;remaining_sensors];  %randperm(size(remaining_idx,1),1);
% select_rx = rx(remaining_index,:);
% 
% figure;
% scatter(rx(:,1),rx(:,2));
% hold on;
% scatter(tx_positions(:,1),tx_positions(:,2));
% hold off
%% RX calculation
% Define the size of the grid
clc;
clear all;
gridSize = [100, 100];
Len = gridSize(1,1);
Breadth = gridSize(1,2);
% Define the number of total sensors
numSensors = [4,9,16,25,36,49];

% Tx parameters
pu_x = 18; %floor(random('Uniform',0,gridSize(1)));
pu_y = 37; %floor(random('Uniform',0,gridSize(1)));
tx_positions = [pu_x,pu_y];

% Define true transmitter power and path loss exponent
tx_power = -10;     % in dB
path_loss_exp = 3.5; % Path loss exponent

% min reference distance of the transmitter from the receivers.
d_0 = 2;
Numberofexps = 20;

theta_samples = [];
for j = 1:Numberofexps
for k = 1:size(numSensors,2)

% Initialize the grid with zeros
%grid = zeros(gridSize);
 
%Calculate the number of sensors to be placed in each dimension
% numSensorsX = floor(sqrt(numSensors(k)));
% numSensorsY = ceil(sqrt(numSensors(k)));

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
 

% RSS calculation

% Calculate true distances (euclidean distance) between transmitters and receivers
d_true = pdist2(rx, tx_positions);


% define reference path loss = 10*path_loss_exp*log10(d_0) = p_tx- p_rx;
ref_path_loss = -10*path_loss_exp*log10(d_0);  %in dB

tx_path_loss_exp = (d_0^2)*10^(tx_power/(5*path_loss_exp)); % this is - PL_0

%rss_true = calculate_rss(tx_power,path_loss_exp,d_0,d_true);
rss_true = rss_measurements(tx_power,rx,path_loss_exp,d_0,d_true);

% Calling function LiVE to perform localisation in a step by step manner
theta_samples(:,k,j) = calculate_tx_pos(rx,rss_true,path_loss_exp,ref_path_loss,tx_path_loss_exp,Numberofexps);

end
end
%% PLot TRx localisation error and RSS error
theta_samples1 = mean(theta_samples,3);
tx_pos = tx_positions';
localisation_error_fmin = zeros(1,size(theta_samples1,2));
% localisation_error_lsq = zeros(1,size(theta_lsq,2));
 
for k = 1: size(theta_samples1,2)
 
    localisation_error_fmin(1,k) = sqrt((tx_pos(1,1) - theta_samples1(1,k))^2 + (tx_pos(2,1) - theta_samples1(2,k))^2);
    

end

figure;
plot(numSensors,localisation_error_fmin);
xlabel('Number of receivers');
ylabel('Localisation Error');
legend('FminCon LIvE'); %,'LSQnonlin-LIvE Algorithm');
title("Localisation Error");

% save("localisation_using_4_sensors.mat","localisation_error_fmin");
% %localisation_error_fmin = 10*log10(localisation_error_fmin);
% %localisation_error_lsq = 10*log10(localisation_error_lsq);
%% Function to perform Tx localization using LivE method

function theta_samples = calculate_tx_pos(select_rx,rss_true,path_loss_exp,ref_path_loss,tx_path_loss_exp,Num_exps)

% Select 4 receivers with highest RSSI for this transmitter
% [selected_receivers, indices] = maxk(rss, min_no_sensor);
% indices = randperm(iter,4);

A = [];
b = [];

% generating A
% for i=1:size(select_rx,1)     %size(indices,1)
% 
%     A(i,:) =  [2*select_rx(i,1), 2*select_rx(i,2), 10^((- ref_path_loss-rss_true(i))/(5*path_loss_exp)),-1];
% 
% end
% 
% % generate b
% for n = 1:size(select_rx,1)      %size(indices,1)
% 
%     b(n,:) = select_rx(n,1)^2 + select_rx(n,2)^2;
% 
% end


for n=1:size(select_rx,1)-1

    A(n,:) = [2*(select_rx(n+1,1) - select_rx(1,1)), 2*(select_rx(n+1,2) - select_rx(1,2)), 10^(-rss_true(n+1)/(5*path_loss_exp)) - 10^(-rss_true(1)/(5*path_loss_exp)) ];
    %A(n,:) = [2*(rx_positions_iter(n+1,1) - rx_positions_iter(1,1)), 2*(rx_positions_iter(n+1,2) - rx_positions_iter(1,2)), 10^(-selected_receivers(n+1)/(5*path_loss_exp)) - 10^(-selected_receivers(1)/(5*path_loss_exp)) ];
end

for j=1:size(select_rx,1)-1

     b(j,:) = select_rx(j+1,1)^2 + select_rx(j+1,2)^2 - select_rx(1,1)^2 - select_rx(1,2)^2;
end
            
% Base paper Solution to LSS using langrange non linear estimation
% LIve transmitter localisation estimation function calculation.
% In comparison to the non linear least square estimation function we use
% lagrange optimisation problem with the optimization constraint to find
% optimal transmitter solutions.
% least square objective function constructing the objective function to be passed to the langrange
% function as a function handle.
% l_cost_function = @(theta) (A*theta-b)'*(A*theta-b);

%l_cost_function = @(theta,lambda) norm(A*theta-b)^2 + lambda*(r'*theta + theta'*P*theta );
%l_cost_function = @(theta) (A*theta-b)'*(A*theta-b);
for num = 1:Num_exps

d_0 = 2;

fmin = @(x) rss_cost_function(x, select_rx, rss_true, d_0, path_loss_exp);

% function handle g as a constraint to be minimised.
%g = @(theta) r'*theta + theta'*P*theta;

% lagrange function to be minimised for optimal theta_hat and lagrange
% multiplier for optimal solution lambda

%lagrange_function = @(theta,lambda) cost_function + lambda*g;

% Define the options for the fmincon solver
options = optimoptions('fmincon', 'MaxIterations', 10000, 'TolFun', 1e-21,'Algorithm','interior-point',"EnableFeasibilityMode",true);

% define the initial guess as a  starting point for transmitter
% localisation.

x_0 = [2; 2; tx_path_loss_exp];

% nonlinear constaraint generator using dea function to pass to the fmincon
% function. empty matrix for non linear inequality.

nonlcon = @constraint; 
% fmincon functin to find the optimal minimum function to estimate the
% transmitter location and lagrange optimiser.
% Function fmincon definition : x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options).

[theta_hat,fval,~,output,lambda] = fmincon(fmin,x_0,[],[],A,b,[],[],nonlcon,options);
theta_avg(:,num) = theta_hat; 
end

temp2 = mean(theta_avg,2);
theta_samples = temp2;

% options = optimoptions('lsqnonlin','MaxFunctionEvaluations',15000,'Algorithm','interior-point');

% % Least squares function:
% lsq = @(x) lsq_cost_function(x, select_rx, rss_true, d_0);
% 
% % Optimize the cost function using the least squares method
% [x_opt, ~, ~, ~, output] = lsqnonlin(lsq, x_0,[],[],A,b,[],[],nonlcon,options);

%theta_lsq = [theta_lsq x_opt]; 

end

 
%% Display the estimated transmitter location and optimization details
%fprintf('Estimated transmitter location: (%f, %f)\n', theta_hat(1), theta_hat(2));
% fprintf('Number of function evaluations: %d\n', output.funcCount);
% fprintf('Number of iterations: %d\n', output.iterations);
 
% % Plot the true and estimated transmitter locations and the RSS values
% figure;
% scatter(rx_positions(:,1),rx_positions(:,2),'filled','b');
% hold on
% scatter(tx_positions(:,1), tx_positions(:,2), 'filled', 'r');
% scatter(theta_hat(1), theta_hat(2), 'filled', 'g');
% hold off
% legend('Receiver', 'True Transmitter', 'Estimated Transmitter');
% xlabel('x (m)');
% ylabel('y (m)');
% title('Active Transmitter Location Estimation');

%% rss cost function definition 

% Cost function for least squares optimization
function fmin = rss_cost_function(x, rx, rss, d_0, path_loss_exp )

    % Calculate distances between receivers and estimated transmitter
    d = sqrt((rx(:,1)-x(1)).^2 + (rx(:,2)-x(2)).^2);
    tx_power = -10;

    % Calculate predicted RSS values using estimated transmitter location
    
    rss_pred = rss_measurements(tx_power,rx, path_loss_exp,d_0,d);
    % Calculate the difference between predicted and true RSS values
    fmin = rss_pred(:) - rss(:);
    fmin = sum(fmin);
    
end

%% Cost function for least squares optimization
function lsq = lsq_cost_function(x, rx, rss, d_0,path_loss_exp)
    % Calculate distances between receivers and estimated transmitter
    d = sqrt((rx(:,1)-x(1)).^2 + (rx(:,2)-x(2)).^2);
    % Calculate predicted RSS values using estimated transmitter location
    %rss_pred = -10*path_loss_exp*log10(d/d_0) + rss(1,:);
    rss_pred = -10*path_loss_exp*log10(d/d_0) ;
    % Calculate the difference between predicted and true RSS values
    lsq = rss_pred(:) - rss(:);
    lsq = lsq.^2;

end


%% non linear inequality or equality function generation

function [c,ceq] = constraint(theta)
    P = zeros(3,3);
    P(1,1) = 1;
    P(2,2) = 1;
    r = [0;0;-1];
    c=[];
    ceq = r'*theta + theta.'*P*theta;
end


