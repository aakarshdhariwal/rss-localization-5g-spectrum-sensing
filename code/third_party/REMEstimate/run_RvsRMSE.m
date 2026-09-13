%% 2012 01 11 PREPARING 
% setting the parameters
clc;
clear all;
close all;

tStart=tic;

num_of_runs = 40;

edge_width = 1000; %meters
edge_height = 1000; %meters

num_of_sensors_d = 4;

num_grid_x = 100;
num_grid_y = 100;

pu_txPower = 0.1; %watt

channel.name = 'SUB_URBAN';
channel.ploss_exp = 4.02;
channel.ploss_corr = 27.7;
channel.sigma = 8;

[ r_arr, rmse_arr ] = eval_RvsRMSE(edge_width, edge_height, num_of_sensors_d, num_grid_x, num_grid_y, pu_txPower, channel, num_of_runs );
rmse_arr_smooth = imfilter(rmse_arr, fspecial('average', [1 2]), 'replicate');

%% PLOT 
figure();
plot(r_arr, rmse_arr_smooth(1,:), '-c*', 'LineWidth', 3);
hold on;
grid on;
plot(r_arr, rmse_arr_smooth(2,:), '--m', 'LineWidth', 3);
plot(r_arr, rmse_arr_smooth(3,:), ':k', 'LineWidth', 3);
plot(r_arr, rmse_arr_smooth(4,:), '-bs', 'LineWidth', 3);
xlabel('Distance to closest sensor (m)', 'fontsize',13,'fontweight','b');
ylabel('RMSE', 'fontsize',13,'fontweight','b')
xlim([0 140]);
ylim([8 12.5]);
legend('IDW1', 'IDW2', 'Krigging', 'Loc. Estimation', 2);
set(gca, 'fontsize',11, 'FontWeight','bold');
hold off;

tElapsed=toc(tStart);
fprintf(1,'Finished in %f minutes\n', tElapsed/60);


%% PLOT Merged RMSE Figure


figure();
subplot(1,3,1)
semilogx(roc_idw1.fazr, roc_idw1.cdzr,        ':*', 'MarkerSize', 8, 'LineWidth', 3, 'Color', [0 0.5 0.4]);
xlabel('FAZR', 'fontsize',11,'fontweight','d','fontangle','italic')
ylabel('CDZR_1', 'fontsize',11,'fontweight','d','fontangle','italic')
title('ROC Curves', 'FontWeight','bold');
set(gca, 'fontsize',9, 'FontWeight','bold');
ylim([0 1]);
xlim([0.0001 0.1])
set(gca,'LineWidth',1.1)
grid on;
hold all;
semilogx(roc_idw2.fazr, roc_idw2.cdzr,        '--', 'LineWidth', 3, 'Color', [0.33 0.67 0.4]);
semilogx(roc_krig.fazr, roc_krig.cdzr,           '-', 'LineWidth', 3, 'Color', [0.66 0.84 0.4]);
semilogx(roc_locaWoutTx.fazr, roc_locaWoutTx.cdzr,       '-s', 'MarkerFaceColor', [0 0.5 0.4], 'MarkerEdgeColor', [0 0.5 0.4], 'LineWidth', 3, 'Color', [1 1 0.4]);
legend('IDW1', 'IDW2', 'Kriging', 'Loc. Det. Based', 2);
hold off;

subplot(1,3,2)
bar([grid_idw1_rmse,            grid_idw2_rmse,             grid_krig_rmse,             grid_loca_rmse; ...
    grid_idw1_rmse_smooth,      grid_idw2_rmse_smooth,      grid_krig_rmse_smooth,      grid_loca_rmse_smooth]);
legend('IDW1', 'IDW2', 'Krigging', 'Loc. Det. Based', 1);
ylabel('RMSE', 'fontsize',11,'fontweight','b','fontangle','italic')
ylim([0 16])
set(gca, 'XTickLabel',{'True REM','Smoothed REM'}, 'fontsize',9, 'FontWeight','bold')
set(gca,'LineWidth',1.1)
colormap(summer)
title('RMSE WRT True and Smoothed REM', 'FontWeight','bold');


subplot(1,3,3)
plot(r_arr, rmse_arr_smooth(1,:), ':*', 'MarkerSize', 8, 'LineWidth', 3, 'Color', [0 0.5 0.4]);
hold on;
grid on;
plot(r_arr, rmse_arr_smooth(2,:), '--', 'LineWidth', 3, 'Color', [0.33 0.67 0.4]);
plot(r_arr, rmse_arr_smooth(3,:), '-', 'LineWidth', 3, 'Color', [0.66 0.84 0.4]);
plot(r_arr, rmse_arr_smooth(4,:), '-s', 'MarkerFaceColor', [0 0.5 0.4], 'MarkerEdgeColor', [0 0.5 0.4], 'LineWidth', 3, 'Color', [1 1 0.4]);
xlabel('Distance to closest sensor (m)', 'fontsize',11,'fontweight','b');
ylabel('RMSE', 'fontsize',11,'fontweight','b','fontangle','italic')
xlim([0 140]);
ylim([8 14]);
legend('IDW1', 'IDW2', 'Krigging', 'Loc. Det. Based', 2);
set(gca, 'fontsize',9, 'FontWeight','bold');
set(gca,'LineWidth',1.1)
hold off;
title('Distance Versus RMSE', 'FontWeight','bold');

