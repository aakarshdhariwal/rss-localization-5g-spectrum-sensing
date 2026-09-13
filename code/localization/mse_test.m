%% selecting sensors and defining grid in another manner

% edge_width = 100;  %meters
% edge_height = 100; %meters
% 
% num_of_sensors_d = 4;
% num_of_sensors = num_of_sensors_d.^2;
% 
% %num_of_regions = num_of_sensors;
% 
% num_grid_x = 100;
% num_grid_y = 100;
% 
% %primary trx location
% pu_x = 67; %random('Uniform',0,edge_width);
% pu_y = 41; %random('Uniform',0,edge_height);
% 
% [XSens, YSens] = meshgrid((0.5*edge_width/num_of_sensors_d):edge_width/num_of_sensors_d:edge_width, (0.5*edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);
% rx = [XSens(:),YSens(:)];
% sensor_dist_arr = ((XSens-pu_x).^2 + (YSens-pu_y).^2).^0.5;
% 
% [XGrid,YGrid] = meshgrid((0.5*edge_width/num_grid_x):edge_width/num_grid_x:edge_width, (0.5*edge_height/num_grid_y):edge_height/num_grid_y:edge_height);
% grid_dist_arr = ((XGrid-pu_x).^2 + (YGrid-pu_y).^2).^0.5;
% 
% corner = [XSens(1,1),YSens(1,1);XSens(1,end),YSens(1,1);XSens(1,1),YSens(end,1);XSens(1,end),YSens(end,1)];
% temp = ismember(rx,corner,'rows');
% ind = find(temp);
% remaining_sensors = find(temp==0);
% remaining_index = [ind;remaining_sensors];%randperm(size(remaining_idx,1),1);
% select_rx = rx(remaining_index,:);
% 
% % figure;
% % scatter(XGrid(:),YGrid(:));
% % figure;
% % scatter(XSens(:),YSens(:));
% 
% figure;
% scatter(rx(:,1),rx(:,2));

%% RX calculation

% Define the size of the grid
clc;
clear all;
radius_theta = [];
%for l=1:4
gridSize = [100, 100];
Len = gridSize(1,1);
Breadth = gridSize(1,2);
% Define the number of total sensors
numSensors = [4,9,16,25,36,49];

%numSensors = 36;

% Tx parameters
pu_x = 18; %floor(random('Uniform',0,gridSize(1)));
pu_y = 37; %floor(random('Uniform',0,gridSize(1)));
tx_positions = [pu_x, pu_y];

% Define true transmitter power and path loss exponent
tx_power = -10;    % in dB

% OFDM Waveform generator function call. Parameters include (modulation
% symbol,Nfft, cyclic prefx,total symbols to generate).
M = 4;
nfft = 128;
cplen = 16;
nSym = 28; % 5ms subframe with 14 ofdm symbols
%[ofdm_tx_signal,ofdm_parameters] = ofdm(M,nfft,cplen,nSym);
% save('ofdm_tx_signal.mat',"ofdm_tx_signal");

% ofdm_tx = load('ofdm_tx_signal.mat');
% ofdm_tx_signal = ofdm_tx.ofdm_tx_signal;
% parameters = load('ofdm_parameters.mat');
% ofdm_parameters = parameters.ofdm_parameters;

path_loss_exp = 3.5; % Path loss exponent

% min reference distance of the transmitter from the receivers.
d_0 = 2;
Numberofexps = 25;
theta_stack = [];
theta_samples = [];


for iter = 1:Numberofexps
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

%scatter plot for sensors and total area
figure;
scatter(x(:),y(:),'filled','b');
hold on;
scatter(tx_positions(1,1),tx_positions(1,2),'filled','r');
hold off;
grid on;
title('Dedicated Sensor Network');
xlabel('Position x (m)');
ylabel('Position y (m)');
legend("Sensor Nodes"," True transmitter position");


%[X, Y] = meshgrid(spacingX:spacingX:gridSize(1)-spacingX, spacingY:spacingY:gridSize(2)-spacingY);
 

% Calculate true distances (euclidean distance) between transmitters and receivers
d_true = pdist2(rx, tx_positions);
%d_true = pdist2(select_rx,tx_positions);

% Generating Received Signal Strength levels

rss_true = rss_measurements(tx_power,rx,path_loss_exp,d_0,d_true);
%rss_true = rss_measurements_ofdm(ofdm_tx_signal,ofdm_parameters,path_loss_exp,d_0,d_true);
%rss_true = calculate_rss(ofdm_tx_signal,rx,path_loss_exp,d_0,d_true);

% Calculating estimated Tx positions
theta_samples(:,k)  = calculate_tx_pos(tx_positions',rx,rss_true,Numberofexps,path_loss_exp);

end
theta_stack = [theta_stack;theta_samples(1:2,:)]; 
end
%radius_theta = [radius_theta theta_samples];
%end
%% To calculate localisation error against number of receivers.

tx_pos = tx_positions';
localisation_error = zeros(1,size(theta_samples,2));

for k = 1: size(theta_samples,2)
    
    localisation_error(1,k) = sqrt((tx_pos(1,1) - theta_samples(1,k))^2 + (tx_pos(2,1) - theta_samples(2,k))^2);
    
end

%localisation_error = 10*log10(localisation_error);
%% plot localisatipn eroor against number of receivers

figure;
plot(numSensors,localisation_error);
xlabel('Number of Sensor Nodes');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE');

%% PLoT REM Area Plot using surf function

% First create area grid
edge_width = Len;
edge_height = Breadth;
num_grid = 40;
[XGrid,YGrid] = meshgrid((edge_width/num_grid):edge_width/num_grid:edge_width, (edge_height/num_grid):edge_height/num_grid:edge_height);

f = 3.7e9;
c = 3e8;
wavelength = c/f;
contsant = (wavelength/(4*pi*d_0));

%Plot True REM for Grid size 

rss_grid = zeros(size(XGrid));
path_loss = tx_power - 10*path_loss_exp*log10((0.01+sqrt((tx_positions(1,1)-XGrid).^2 + (tx_positions(1,2)-YGrid).^2))/d_0) + 20*log10(contsant);
rss_grid = rss_grid + path_loss;
rss_grid = normrnd(rss_grid,8);


figure;
surf (XGrid, YGrid, rss_grid, 'EdgeColor', 'none', 'DisplayName', 'True REM');
view(2);
xlabel("Position x (m)");
ylabel("Position y (m)");
%zlabel("RSS measurement (dB)")
title('True REM', 'FontWeight','bold');
c= colorbar;
c.Label.String = 'Power levels in dB';
xlim([0 100]);
ylim([0 100]);
set(gca,'XTick', (0:10:100));


% Estimated REM using estimated TRX position after MSE localization
rss_estimated = zeros(size(XGrid));
path_loss = tx_power - 10*path_loss_exp*log10((0.01+sqrt((theta_samples(1,end)-XGrid).^2 + (theta_samples(2,end)-YGrid).^2))/d_0) + 20*log10(contsant);
rss_estimated = rss_estimated + path_loss;
rss_estimated = normrnd(rss_estimated,8);

figure;
surf (XGrid, YGrid, rss_estimated , 'EdgeColor', 'none', 'DisplayName', 'Estimated REM');
view(2);
title('Estimated REM', 'FontWeight','bold');
xlabel("Position x (m)");
ylabel("Position y (m)");
c=colorbar;
c.Label.String = 'Power levels in dB';
xlim([0 100]);
ylim([0 100]);
set(gca,'XTick', (0:10:100));

%% function for mse.
 
function theta_samples = calculate_tx_pos(tx_pos,rx,rss_true,Numberofexps,path_loss_exp)
 
  %for iter = 1:Numberofexps
    sum1=0;
    sum2=0;
    %rx = select_rx(1:m,:);
    m = size(rx,1);
    %rss = rss_true(1:m);
    Nsamples = nchoosek(m,4);
        for i = 1:Nsamples

            msize = size(rx,1);
            %[selected_receivers,idx] = maxk(rss_true,4);
            idx = randperm(msize,3);
            rx_positions_iter = rx(idx,:);
            %rss_true = selected_receivers;
            
            A=[];
            b=[];
            
            for n=1:size(rx_positions_iter,1)-1
        
                    A(n,:) = [2*(rx_positions_iter(n+1,1) - rx_positions_iter(1,1)), 2*(rx_positions_iter(n+1,2) - rx_positions_iter(1,2)), 10^(-rss_true(idx(n+1),:)/(5*path_loss_exp)) - 10^(-rss_true(idx(1),:)/(5*path_loss_exp)) ];
                    %A(n,:) = [2*(rx_positions_iter(n+1,1) - rx_positions_iter(1,1)), 2*(rx_positions_iter(n+1,2) - rx_positions_iter(1,2)), 10^(-selected_receivers(n+1)/(5*path_loss_exp)) - 10^(-selected_receivers(1)/(5*path_loss_exp)) ];
            end
            
            
            for j=1:size(rx_positions_iter,1)-1
            
                     b(j,:) = rx_positions_iter(j+1,1)^2 + rx_positions_iter(j+1,2)^2 - rx_positions_iter(1,1)^2 - rx_positions_iter(1,2)^2;
            end
            
            num = A'*b;
            sum1 = sum1 + num;
            den= A'*A;
            sum2= sum2+den;
            temp = pinv(den)*num;
            %mse_error(iter,i) = (b - A*temp)'*(b - A*temp);
            
        end
     
    
    theta_opt = pinv(sum2)*sum1;
    %theta_avg(:,iter)  = theta_opt; 
    
  %end
  
%mean_loc_error = mean(sqrt((tx_pos(1,1) - theta_avg(1,:)).^2 + (tx_pos(2,1) - theta_avg(2,:)).^2));        
%temp2 = mean(theta_avg,2);

%theta_samples = [theta_samples temp2];
%theta_samples = temp2;
theta_samples = theta_opt;
end

 