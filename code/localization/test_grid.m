%% test 
% Define the size of the grid
gridSize = [50, 50];

% Define the total number of sensors
numSensors = 16;

% Initialize the grid with zeros
grid = zeros(gridSize);

% Place the corner sensors
cornerPositions = [1, 1; 1, gridSize(2); gridSize(1), 1; gridSize];
grid(sub2ind(gridSize, cornerPositions(:, 1), cornerPositions(:, 2))) = 1;

%Calculate the number of remaining sensors to be placed inside the grid
remainingSensors = numSensors - size(cornerPositions, 1);

% Calculate the number of sensors to be placed per row and column
numSensorsPerRow = floor(sqrt(remainingSensors));
numSensorsPerColumn = ceil(remainingSensors / numSensorsPerRow);

% Calculate the spacing between the sensors
spacingX = gridSize(1) / (numSensorsPerRow + 1);
spacingY = gridSize(2) / (numSensorsPerColumn + 1);

% Place the remaining sensors uniformly inside the grid
for i = 1:remainingSensors
    row = mod(i - 1, numSensorsPerRow) + 1;
    col = floor((i - 1) / numSensorsPerRow) + 1;
    
    x = (row * spacingX);
    y = (col * spacingY);
    
    grid(round(x), round(y)) = 1;
end
[rows,cols] = find(grid==1);
%[row,col]= ind2sub(numSensors,ind);
rx = [cols(:),rows(:)];
% Display the resulting grid
%imshow(grid);
figure;
scatter(rx(:,1),rx(:,2));
%% test 2
clc;
clear all;
edge_width = 1000; %meters
edge_height = 1000; %meters

num_of_sensors_d = 4;
num_of_sensors = num_of_sensors_d.^2;

%num_of_regions = num_of_sensors;

num_grid_x = 100;
num_grid_y = 100;

%primary trx location
pu_x = 670;%random('Uniform',0,edge_width);
pu_y = 471;%random('Uniform',0,edge_height);


[XSens, YSens] = meshgrid((0.5*edge_width/i):edge_width/num_of_sensors_d:edge_width, (0.5*edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);
rx = [XSens(:),YSens(:)];
sensor_dist_arr = ((XSens-pu_x).^2 + (YSens-pu_y).^2).^0.5;

[XGrid,YGrid] = meshgrid((0.5*edge_width/num_grid_x):edge_width/num_grid_x:edge_width, (0.5*edge_height/num_grid_y):edge_height/num_grid_y:edge_height);
grid_dist_arr = ((XGrid-pu_x).^2 + (YGrid-pu_y).^2).^0.5;

corner = [XSens(1,1),YSens(1,1);XSens(1,end),YSens(1,1);XSens(1,1),YSens(end,1);XSens(1,end),YSens(end,1)];
temp = ismember(rx,corner,'rows');
ind = find(temp);
remaining_sensors = find(temp==0);
remaining_index = [ind;remaining_sensors];%randperm(size(remaining_idx,1),1);
select_rx = rx(remaining_index,:);
% figure;
% scatter(XGrid(:),YGrid(:));
% figure;
% scatter(XSens(:),YSens(:));
% figure;
% scatter(rx(:,1),rx(:,2));
%% Test number 3

% Define the size of the grid
gridSize = [100, 100];

% Define the number of total sensors
numSensors = 16;

% Initialize the grid with zeros
grid = zeros(gridSize);

% Place the 4 corner sensors
% grid(1, 1) = 1;
% grid(1, gridSize(2)) = 1;
% grid(gridSize(1), 1) = 1;
% grid(gridSize(1), gridSize(2)) = 1;

% Compute the number of remaining sensors
% remainingSensors = numSensors - 4;

% Calculate the number of sensors to be placed in each dimension
numSensorsX = floor(sqrt(numSensors));
numSensorsY = ceil(sqrt(numSensors));

% Calculate the spacing between sensors in each dimension
spacingX = gridSize(1) / (numSensorsX + 1);
spacingY = gridSize(2) / (numSensorsY + 1);

% Generate the coordinates for the remaining sensors using meshgrid
[X, Y] = meshgrid(spacingX:spacingX:gridSize(1)-spacingX, spacingY:spacingY:gridSize(2)-spacingY);

% Place the remaining sensors inside the grid
for i = 1:numel(X)
    grid(round(X(i)), round(Y(i))) = 1;
end

%grid = [X(:),Y(:)];
[row,col]= find(grid==1);
rx = [row,col];
figure;
scatter(rx(:,1),rx(:,2));
%ind_1 = sub2ind(num_of_sensors,row,col);

%% RSS calculation% Define transmitter and receiver positions
% tx_positions = [4,5];
tx_positions = [pu_x,pu_y];

% Define true transmitter power and path loss exponent
tx_power = -10; % in dB
path_loss_exp = 3.5; % Path loss exponent

% Calculate true distances (euclidean distance) between transmitters and receivers
% d_true = pdist2(rx, tx_positions);
d_true = pdist2(select_rx,tx_positions);
% min reference distance of the transmitter from the receivers.
d_0 = 2;
% define reference path loss = 10*path_loss_exp*log10(d_0) = p_tx- p_rx;
ref_path_loss = 38.4;  %in dB

Num_exps = 15;

tx_path_loss_exp = 10^(tx_power/(5*path_loss_exp));

%rss_true = calculate_rss(tx_power,path_loss_exp,d_0,d_true);
rss_true = rss_measurements(tx_power,path_loss_exp,d_0,d_true);


