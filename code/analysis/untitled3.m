numSensors = [4,9,16,25,36,49];

corr_noise_std_0 = load("corr_noise_std_0.mat","localisation_error");
local_error_std_0 = corr_noise_std_0.localisation_error ;

corr_noise_std_4 = load("corr_noise_std_4.mat","localisation_error");
local_error_std_4 = corr_noise_std_4.localisation_error ;

corr_noise_std_6 = load("corr_noise_std_6.mat","localisation_error");
local_error_std_6 = corr_noise_std_6.localisation_error ;

corr_noise_std_8 = load("corr_noise_std_8.mat","localisation_error");
local_error_std_8 = corr_noise_std_8.localisation_error ;



%% Plot

figure;
subplot(4,1,1)
plot(numSensors,local_error_std_0);
xlabel('Number of Receivers');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE (m)');
legend("\sigma = 0 dB");

subplot(4,1,2)
plot(numSensors,local_error_std_4);
xlabel('Number of Receivers');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE (m)');
legend("\sigma = 4 dB");

% subplot(4,1,3)
% plot(numSensors,local_error_std_6);
% xlabel('Number of Receivers');
% ylabel('Localisation Error (m)');
% title('Transmitter Location Estimation using MSE ');
% legend("\sigma = 6 dB");

subplot(4,1,3)
plot(numSensors,local_error_std_8);
xlabel('Number of Receivers');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE (m)');
legend("\sigma = 8 dB");

%% Plot together

figure();

plot(numSensors,local_error_std_0);
hold on;
plot(numSensors,local_error_std_4);
hold on;
% plot(numSensors,local_error_std_6);
hold on;
plot(numSensors,local_error_std_8);
hold off;
xlabel('Number of sensor nodes');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE (m)');
legend("\sigma = 0 dB","\sigma = 4 dB","\sigma = 8 dB");

%% Smoothed REM try

% runs = 20;
% 
% theta_hat = [17.6; 36.044];
% 
% tx_pos =[18; 37];
% 
% Len = 100;
% Breadth = 100;
% 
% edge_width = Len;
% edge_height = Breadth;
% 
% num_grid = 40;
% [XGrid,YGrid] = meshgrid((edge_width/num_grid):edge_width/num_grid:edge_width, (edge_height/num_grid):edge_height/num_grid:edge_height);
% % generate rem matrix 
% d_0 = 2;
% path_loss_exp = 3.5;
% tx_power = -10; 
% f = 2.5e9;
% c = 3e8;
% wavelength = c/f;
% contsant = (wavelength/(4*pi));
% 
% noise_std_dev = 8; 
% rem_estimated = zeros(size(XGrid,1),size(XGrid,2),runs);
% 
% for i=1:runs
%     gaussian_noise = normrnd(0, noise_std_dev);
%     path_loss = tx_power + 20*log10(contsant) ...
%     - 10*path_loss_exp*log10((sqrt((theta_hat(1,1)-XGrid).^2 + (theta_hat(2,1)-YGrid).^2))/d_0) + gaussian_noise;
% 
%     rem_estimated(:,:,i) = path_loss;
% end
% 
% 
% figure;
% surf (XGrid, YGrid, smoothXY_overRuns(rem_estimated) , 'EdgeColor', 'none', 'DisplayName', 'Estimated REM');
% view(2);
% title('Reconstructed REM', 'FontWeight','bold');
% colorbar;
% xlim([0 100]);
% ylim([0 100]);
% set(gca,'XTick', (0:10:100));
% 
% 
% function output  = smoothXY_overRuns(inp)
% 
% sz_inp = size(inp);
% 
% output = sum(inp, 3);
% 
% output = output / sz_inp(3);
% 
% end

%% Rem

% rss_grid = zeros(size(XGrid));
% path_loss = tx_power - 10*path_loss_exp*log10((0.01+sqrt((tx_positions(1,1)-XGrid).^2 + (tx_positions(1,2)-YGrid).^2))/d_0);
% rss_grid = rss_grid + path_loss;
% rss_grid = normrnd(rss_grid,8);

% rss_estimated = zeros(size(XGrid));
% path_loss = tx_power - 10*path_loss_exp*log10((0.01+sqrt((theta_samples(1,end)-XGrid).^2 + (theta_samples(2,end)-YGrid).^2))/d_0);
% rss_estimated = rss_estimated + path_loss;
% rss_estimated = normrnd(rss_estimated,8);

rss = [];
for i=1:100
for n=1:size(XGrid,1)
    for m = 1:size(XGrid,2)
        rss(n,m,i) = rss_grid(n,m) + normrnd(0,8);

    end
end
end
rss = mean(rss,3);
figure;
surf (XGrid, YGrid, rss, 'EdgeColor', 'none', 'DisplayName', 'True REM');
view(2);
xlabel("Position x (m)");
ylabel("Position y (m)");
zlabel("RSS measurement (dB)")
title('True REM', 'FontWeight','bold');
colorbar;
xlim([0 100]);
ylim([0 100]);
set(gca,'XTick', (0:10:100));

%% extra plot

tx_pos = tx_positions';
localisation_error = zeros(1,size(radius_theta,2));

for k = 1: size(radius_theta,2)
    
    localisation_error(1,k) = sqrt((tx_pos(1,1) - radius_theta(1,k))^2 + (tx_pos(2,1) - radius_theta(2,k))^2);
    
end

% plot localisatipn eroor against number of receivers

figure;
plot([1:4]*100,localisation_error);
xlabel('Radius (m)');
ylabel('Localisation Error (m)');
title('Transmitter Location Estimation using MSE');


%% local error

tx_pos = tx_positions';
localisation_error = zeros(size(theta_stack,1)/2,size(theta_samples,2));
for j = 1:2:size(theta_stack,1)
    temp = theta_stack(j:j+1,:);
for k = 1: size(theta_stack,2)
    
    localisation_error(j,k) = sqrt((tx_pos(1,1) - temp(1,k))^2 + (tx_pos(2,1) - temp(2,k))^2);
    
end
end


