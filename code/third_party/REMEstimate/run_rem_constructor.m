%% 2011 12 26 PREPARING 
% setting the parameters
clc;
clear all;
%close all;

num_of_runs = 20;
TW = 10;

edge_width = 1000; %meters
edge_height = 1000; %meters

num_of_sensors_d = 4;
num_of_sensors = num_of_sensors_d^2;

%num_of_regions = num_of_sensors;

num_grid_x = 100;
num_grid_y = 100;

%primary trx location
pu_x = 670;%random('Uniform',0,edge_width);
pu_y = 471;%random('Uniform',0,edge_height);
pu_txPower = 0.1; %watt

channel.name = 'URBAN';
channel.ploss_exp = 3.5;
channel.ploss_corr = 38.4;
channel.sigma = 8;


[XSens, YSens] = meshgrid((0.5*edge_width/num_of_sensors_d):edge_width/num_of_sensors_d:edge_width, (0.5*edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);
sensor_dist_arr = ((XSens-pu_x).^2 + (YSens-pu_y).^2).^0.5;


[XGrid,YGrid] = meshgrid((0.5*edge_width/num_grid_x):edge_width/num_grid_x:edge_width, (0.5*edge_height/num_grid_y):edge_height/num_grid_y:edge_height);
grid_dist_arr = ((XGrid-pu_x).^2 + (YGrid-pu_y).^2).^0.5;
%% scatter plot for sensors and total area
figure(1);
scatter(XSens(:),YSens(:),'filled','b');
figure(2);
scatter(XGrid(:),YGrid(:),'filled','g');


%% SIMULATION STARTS HERE
sensor_measurement_arr = zeros(num_of_sensors_d, num_of_sensors_d, num_of_runs);
grid_measurement_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
grid_idw1_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
grid_idw2_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
grid_krig_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
grid_loca_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs); % this should be LIvE Rem grid

sensor_mean_powr_arr = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(0.01+sensor_dist_arr);
grid_mean_powr_arr = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(grid_dist_arr);
for ind=1:num_of_runs
    % measurement at SENSOR points
    sensor_measurement_arr(:,:,ind) = normrnd(sensor_mean_powr_arr, channel.sigma/TW^0.5) ;
    
    % measurement at GRID points
    grid_measurement_arr(:,:,ind) = normrnd(grid_mean_powr_arr, channel.sigma/TW^0.5) ;
    
    % estimates using sensor data 
    grid_idw1_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'IDW1');
    grid_idw2_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'IDW2');
    grid_krig_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'KRIG');
    grid_loca_estimate_arr(:,:,ind) = estimate_power_ext(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'LOCA', channel, pu_txPower);
end



%% CDZ MDZ FAZ
%grid_measurement_smooth=imfilter(grid_measurement_arr(:,:,:), fspecial('average', 7), 'replicate');

% contour graph is ploted at the end
Threshold = -120;

%Grid_real_mask = grid_measurement_smooth > Threshold;

%%
fazr_arr = [0.00001 0.00005 0.00007 0.0001 0.0005 0.0007 0.001 0.002 0.005 0.007 0.01 0.03 0.05 0.08 0.1];
realThreshold = -120;%dB

roc_idw1 = prepareROC(grid_measurement_arr, grid_idw1_estimate_arr, fazr_arr, realThreshold);
roc_idw2 = prepareROC(grid_measurement_arr, grid_idw2_estimate_arr, fazr_arr, realThreshold);
roc_krig = prepareROC(grid_measurement_arr, grid_krig_estimate_arr, fazr_arr, realThreshold);
roc_locaWoutTx = prepareROC(grid_measurement_arr, grid_loca_estimate_arr, fazr_arr, realThreshold);



%% PLOT ROC FAZR vs CDZR_1

figure('Name', 'ROC');
semilogx(roc_idw1.fazr, roc_idw1.cdzr,        '-','LineWidth',2.5, 'Color', [0 0.2 0.9], 'MarkerSize',8);
xlabel('FAZR', 'fontsize',12,'fontweight','d','fontangle','italic')
ylabel('CDZR_1', 'fontsize',12,'fontweight','d','fontangle','italic')
ylim([0 1]);
set(gca,'LineWidth',1.5)
grid on;
hold all;
semilogx(roc_idw2.fazr, roc_idw2.cdzr,        '-+','LineWidth',2.5, 'Color', [0.1 0.5 0.1], 'MarkerSize',8);
semilogx(roc_krig.fazr, roc_krig.cdzr,        '--','LineWidth',2.5, 'Color', [0.9 0 0], 'MarkerSize',8);
semilogx(roc_locaWoutTx.fazr, roc_locaWoutTx.cdzr,        '-s','LineWidth',2.5, 'Color', [0.7 0.1 0.7], 'MarkerSize', 8);
%legend('IDW1', 'IDW2', 'Kriging', 'LIvE REM', 2);
legend('IDW1', 'IDW2', 'Kriging', 'LIvE REM', 'Location', 'NorthWest');
hold off;


% Grid_idw1_mask = grid_idw1_estimate_arr > Threshold-19.54;
% Grid_idw2_mask = grid_idw2_estimate_arr > Threshold-14.44;
% Grid_krig_mask = grid_krig_estimate_arr > Threshold-10.5;
% Grid_loca_mask = grid_loca_estimate_arr > Threshold-14.2;
% 
% CDZ_idw1 = nnz(Grid_idw1_mask & Grid_real_mask)/nnz(Grid_real_mask);
% MDZ_idw1 = nnz(~Grid_idw1_mask & Grid_real_mask)/nnz(Grid_real_mask);
% FAZ_idw1 = nnz(Grid_idw1_mask & ~Grid_real_mask)/nnz(~Grid_real_mask);
% 
% CDZ_idw2 = nnz(Grid_idw2_mask & Grid_real_mask)/nnz(Grid_real_mask);
% MDZ_idw2 = nnz(~Grid_idw2_mask & Grid_real_mask)/nnz(Grid_real_mask);
% FAZ_idw2 = nnz(Grid_idw2_mask & ~Grid_real_mask)/nnz(~Grid_real_mask);
% 
% CDZ_krig = nnz(Grid_krig_mask & Grid_real_mask)/nnz(Grid_real_mask);
% MDZ_krig = nnz(~Grid_krig_mask & Grid_real_mask)/nnz(Grid_real_mask);
% FAZ_krig = nnz(Grid_krig_mask & ~Grid_real_mask)/nnz(~Grid_real_mask);
% 
% CDZ_loca = nnz(Grid_loca_mask & Grid_real_mask)/nnz(Grid_real_mask);
% MDZ_loca = nnz(~Grid_loca_mask & Grid_real_mask)/nnz(Grid_real_mask);
% FAZ_loca = nnz(Grid_loca_mask & ~Grid_real_mask)/nnz(~Grid_real_mask);


%% PLOT RMSE
grid_idw1_rmse = ( mean(nanmean(reshape((grid_idw1_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
grid_idw2_rmse = ( mean(nanmean(reshape((grid_idw2_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
grid_krig_rmse = ( mean(nanmean(reshape((grid_krig_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
grid_loca_rmse = ( mean(nanmean(reshape((grid_loca_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;

% grid_idw1_rmse_smooth = ( mean(nanmean(reshape((grid_idw1_estimate_arr-grid_measurement_smooth).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
% grid_idw2_rmse_smooth = ( mean(nanmean(reshape((grid_idw2_estimate_arr-grid_measurement_smooth).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
% grid_krig_rmse_smooth = ( mean(nanmean(reshape((grid_krig_estimate_arr-grid_measurement_smooth).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
% grid_loca_rmse_smooth = ( mean(nanmean(reshape((grid_loca_estimate_arr-grid_measurement_smooth).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;

% grid_idw1_err_stdev = mean(nanstd(reshape(grid_idw1_estimate_arr-grid_measurement_arr, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_idw2_err_stdev = mean(nanstd(reshape(grid_idw2_estimate_arr-grid_measurement_arr, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_krig_err_stdev = mean(nanstd(reshape(grid_krig_estimate_arr-grid_measurement_arr, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_loca_err_stdev = mean(nanstd(reshape(grid_loca_estimate_arr-grid_measurement_arr, num_grid_x*num_grid_y, 1, num_of_runs)));

% grid_idw1_err_smooth_stdev = mean(nanstd(reshape(grid_idw1_estimate_arr-grid_measurement_smooth, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_idw2_err_smooth_stdev = mean(nanstd(reshape(grid_idw2_estimate_arr-grid_measurement_smooth, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_krig_err_smooth_stdev = mean(nanstd(reshape(grid_krig_estimate_arr-grid_measurement_smooth, num_grid_x*num_grid_y, 1, num_of_runs)));
% grid_loca_err_smooth_stdev = mean(nanstd(reshape(grid_loca_estimate_arr-grid_measurement_smooth, num_grid_x*num_grid_y, 1, num_of_runs)));

% figure();
% bar([grid_idw1_rmse,            grid_idw2_rmse,             grid_krig_rmse,             grid_loca_rmse; ...
%     grid_idw1_rmse_smooth,      grid_idw2_rmse_smooth,      grid_krig_rmse_smooth,      grid_loca_rmse_smooth]);
% %legend('IDW1', 'IDW2', 'Krigging', 'Loc. Estimation', 1);
% legend('IDW1', 'IDW2', 'Krigging', 'Loc. Estimation');
% ylabel('RMSE', 'fontsize',13,'fontweight','b')
% set(gca, 'XTickLabel',{'WRT True REM','WRT Smoothed REM'}, 'fontweight','b')


%% PLOT AREA MAPs

figure();
subplot(2,3,1)
surf (XGrid, YGrid, smoothXY_overRuns(grid_measurement_arr), 'EdgeAlpha', 0.4, 'DisplayName', 'grid_measurement_arr');
title('True REM', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));

subplot(2,3,2)
contourf (XGrid, YGrid, smoothXY_overRuns(grid_measurement_arr), 'DisplayName', 'XGrid, YGrid, grid_measurement_smoot');
title('Smoothed True REM', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));

subplot(2,3,3)
surf (XGrid, YGrid, smoothXY_overRuns(grid_idw1_estimate_arr), 'EdgeColor', 'none', 'DisplayName', 'grid_estimate_idw1_arr'); 
view(2);
title('Estimated REM - IDW1', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));

subplot(2,3,4)
surf (XGrid, YGrid, smoothXY_overRuns(grid_idw2_estimate_arr), 'EdgeColor', 'none', 'DisplayName', 'grid_estimate_idw2_arr'); 
view(2);
title('Estimated REM - IDW2', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));

subplot(2,3,5)
surf (XGrid, YGrid, smoothXY_overRuns(grid_krig_estimate_arr), 'EdgeColor', 'none', 'DisplayName', 'grid_estimate_krig_arr'); 
view(2);
title('Estimated REM - Krigging', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));

subplot(2,3,6)
surf (XGrid, YGrid, smoothXY_overRuns(grid_loca_estimate_arr), 'EdgeColor', 'none', 'DisplayName', 'grid_estimate_loca_arr');
view(2);
title('Estimated REM - Loc. Det. Based', 'FontWeight','bold');
xlim([0 1000]);
ylim([0 1000]);
set(gca,'XTick', (0:200:1000));






