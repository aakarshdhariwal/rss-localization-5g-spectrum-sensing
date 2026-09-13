%% Corrected MSE code is here 
clc
close all;
clear all;

gridpoints=35;
theta_samples = [];
theta_avg = [];
%for mu = 1:size(gridpoints,2)

gridSizeX = gridpoints; % Number of points along the x-axis
gridSizeY = gridpoints; % Number of points along the y-axis
stepsize = 5;
% Create the rectangular grid
[x, y] = meshgrid(1:stepsize:gridSizeX, 1:stepsize:gridSizeY);
%[x,y] = meshgrid(linspace(1,10,2),linspace(1,10,3));

% Display the grid points
rx_positions = [x(:), y(:)];


% Define transmitter and receiver positions
tx_positions = [4,3];
%rx_positions = [1 1; 4 1; 7 1; 1 4; 4 4; 7 4];


% Define true transmitter power and path loss exponent
tx_power = -10; % in dBm
path_loss_exp = 3.5; % Path loss exponent


% To add log normal shadowing or correlated shadowing to the path loss.


% Calculate true distances (euclidean distance) between transmitters and receivers
d_true = pdist2(rx_positions, tx_positions);
% min reference distance of the transmitter from the receivers.
d_0 = 2;
%rx_positions = flip(rx_positions);
Numberofexps = 20;
rss_true = calculate_rss(tx_power,path_loss_exp,d_0,d_true);
for m = 4:size(rx_positions,1)
    for iter = 1:Numberofexps
    sum1=0;
    sum2=0;
    rx = rx_positions(1:m,:);
   
    %rss = rss_true(1:m);
    Nsamples = nchoosek(m,4);
        for i = 1:Nsamples
            
            msize = size(rx,1);
            idx = randperm(msize,4);
            %[selected_receivers, idx] = maxk(rss_true(1:m), 4);
            %rss = selected_receivers;
            rx_positions_iter = rx(idx,:);
            A=[];
            b=[];
            for n=1:size(rx_positions_iter,1)-1
        
                    A(n,:) = [2*(rx_positions_iter(n+1,1) - rx_positions_iter(1,1)), 2*(rx_positions_iter(n+1,2) - rx_positions_iter(1,2)), 10^(-rss_true(idx(n+1),:)/(5*path_loss_exp)) - 10^(-rss_true(idx(1),:)/(5*path_loss_exp)) ];
        
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
    theta_avg(:,iter)  = theta_opt;
    
    end
        
temp2 = mean(theta_avg,2);
theta_samples = [theta_samples temp2];

end

%% To calculate localisation error against number of receivers

tx_pos = tx_positions';
localisation_error = zeros(1,size(theta_samples,2));

for k = 1: size(theta_samples,2)

    localisation_error(1,k) = sqrt((tx_pos(1,1) - theta_samples(1,k))^2 + (tx_pos(2,1) - theta_samples(2,k))^2);

end
%localisation_error = 10*log10(localisation_error);
%% plot localisatipn eroor against number of receivers
figure;
plot((1/size(localisation_error,2))*localisation_error);
xlabel('Number of Receivers');
ylabel('Localisation Error');

title('Transmitter Location Estimation using MSE');

%% plot power error
tx_opt = theta_samples(1:2,end)';%theta_samples(1:2,46)';
distance_hat = pdist2(tx_opt,rx_positions);
rss_error = zeros(1,size(distance_hat,2));

for l=1:size(distance_hat,2)

    rss_error(1,l) =  10*path_loss_exp*log10(d_true(l)/distance_hat(l));

end

figure;
plot(rss_error);
xlabel('Number of receivers');
ylabel('RSS Error');
title('RSS Error vs Number of receivers');


%% Scatter plot for the transmitter location estimation

% Display the estimated transmitter location and optimization details
%fprintf('Estimated transmitter location: (%f, %f)\n', theta_hat(1), theta_hat(2));
% fprintf('Number of function evaluations: %d\n', output.funcCount);
% fprintf('Number of iterations: %d\n', output.iterations);

% % Plot the true and estimated transmitter locations and the RSS values
% figure;
% scatter(rx_positions(:,1),rx_positions(:,2),'filled','b');
% hold on
% scatter(tx_positions(:,1), tx_positions(:,2), 'filled', 'r');
% scatter(tx_opt(1), tx_opt(2), 'filled', 'g');
% hold off
% hold off
% legend('Receiver', 'True Transmitter', 'Estimated Transmitter');
% xlabel('x (m)');
% ylabel('y (m)');
% title('Active Transmitter Location Estimation');
