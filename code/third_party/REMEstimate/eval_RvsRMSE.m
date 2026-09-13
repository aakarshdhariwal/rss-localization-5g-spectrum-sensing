function [ r_arr, rmse_arr ] = eval_RvsRMSE(edge_width, edge_height, num_of_sensors_d, num_grid_x, num_grid_y,  pu_txPower, channel, num_of_runs )

[XSens, YSens] = meshgrid((0.5*edge_width/num_of_sensors_d):edge_width/num_of_sensors_d:edge_width, (0.5*edge_height/num_of_sensors_d):edge_height/num_of_sensors_d:edge_height);

[XGrid,YGrid] = meshgrid((0.5*edge_width/num_grid_x):edge_width/num_grid_x:edge_width, (0.5*edge_height/num_grid_y):edge_height/num_grid_y:edge_height);

small_grid_halfwidth = 0.45*edge_width / num_of_sensors_d;
small_grid_halfheight = 0.45*edge_height / num_of_sensors_d;

origin_sensor_d = floor(num_of_sensors_d/2);
origin_sensor_x = XSens(origin_sensor_d,origin_sensor_d);
origin_sensor_y = YSens(origin_sensor_d,origin_sensor_d);

%% Start looping on R values
dpoint_ub = 10;
r_arr = zeros(1,dpoint_ub);
rmse_arr = zeros(4, dpoint_ub);
for dpoint=1:dpoint_ub
    dx = dpoint * (small_grid_halfwidth/(dpoint_ub+1));
    dy = dpoint * (small_grid_halfheight/(dpoint_ub+1));
    
    current_pu_x = origin_sensor_x + dx-3.1;
    current_pu_y = origin_sensor_y + dy-3.1;
    
    r_arr(dpoint) = sqrt((current_pu_x-origin_sensor_x)^2 + ((current_pu_y-origin_sensor_y))^2);
    
    sensor_dist_arr = eval_dist2locations(current_pu_x, current_pu_y, XSens, YSens);
    grid_dist_arr = eval_dist2locations(current_pu_x, current_pu_y, XGrid, YGrid);


    %% SIMULATION STARTS HERE
    sensor_measurement_arr = zeros(num_of_sensors_d, num_of_sensors_d, num_of_runs);
    grid_measurement_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
    grid_idw1_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
    grid_idw2_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
    grid_krig_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);
    grid_loca_estimate_arr = zeros(num_grid_x, num_grid_y, num_of_runs);

    sensor_mean_powr_arr = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(sensor_dist_arr);
    grid_mean_powr_arr = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(grid_dist_arr);
    for ind=1:num_of_runs
        % measurement at SENSOR points
        sensor_measurement_arr(:,:,ind) = normrnd(sensor_mean_powr_arr, channel.sigma);

        % measurement at GRID points
        grid_measurement_arr(:,:,ind) = normrnd(grid_mean_powr_arr, channel.sigma);

        % estimates using sensor data 
        grid_idw1_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'IDW1');
        grid_idw2_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'IDW2');
        grid_krig_estimate_arr(:,:,ind) = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'KRIG');
        grid_loca_estimate_arr(:,:,ind) = estimate_power_ext(XGrid, YGrid, XSens, YSens, sensor_measurement_arr(:,:,ind), 'LOCA', channel, pu_txPower);
    end
    
    rmse_arr(1,dpoint) = ( mean(nanmean(reshape((grid_idw1_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
    rmse_arr(2,dpoint) = ( mean(nanmean(reshape((grid_idw2_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
    rmse_arr(3,dpoint) = ( mean(nanmean(reshape((grid_krig_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;
    rmse_arr(4,dpoint) = ( mean(nanmean(reshape((grid_loca_estimate_arr-grid_measurement_arr).^2, num_grid_x*num_grid_y, 1, num_of_runs))) )^0.5;

    fprintf(1,'Outer Run %d / %d Finished\n', dpoint, dpoint_ub);
end % end of <for dpoint>




end

