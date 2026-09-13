function [ out ] = estimate_power_ext( XGrid, YGrid, XSens, YSens, sensor_measurement_arr, est_type, channel, pu_txPower )
% channel.name = 'SUB_URBAN';
% channel.ploss_exp = 4.02;
% channel.ploss_corr = 27.7;
% channel.sigma = 8;

grid_sz = size(XGrid);

if (strcmp(est_type,'LOCA') == 1)

    out = estimate_loca(XGrid, YGrid, XSens, YSens, sensor_measurement_arr, channel, pu_txPower);

else

    out = zeros(grid_sz);
    
end


end


function [out] = estimate_loca(XGrid, YGrid, XSens, YSens, sensor_measurement_arr, channel, pu_txPower)
    % Estimates power according to LOCATION Estimation
    grid_sz = size(XGrid);
    
    d_err_arr = zeros(grid_sz);
    % First evaluate d_err array
    for i=1:grid_sz(1)
        for j=1:grid_sz(2)
            d_err = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(sqrt((XSens-XGrid(i,j)).^2 + (YSens-YGrid(i,j)).^2));
            d_err = (d_err - sensor_measurement_arr).^2; % squared error difference
            d_err_arr(i,j) = sum(sum(d_err)); %what if I take mean value of the 4x4 array?
        end
    end
    
    % Find min or minimums :) that is the candidate location for
    % transmitter. Find corresponding X Y from XGrid YGrid.
    possibleLocationCnt = 20;
    [Temp,IX] = sort(d_err_arr(:)); % temp = d_err_arr(IX);
    % This function takes the value of the indices from the IX which contains the indices of the d_err_arr matrix
    % and then choose the first N or any number min values and create the row and col subscripts (corresponding row and colum of the value in IX)out of it to access
    % the value from the Xgrip and Ygrid.
    [rowt colt] = ind2sub(size(d_err_arr),IX(1:possibleLocationCnt));
    X_trx = XGrid(1,colt);
    Y_trx = YGrid(rowt,1);
    
    
    out = zeros(grid_sz);
    for i=1:possibleLocationCnt
        out = out + 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10(0.01+sqrt((X_trx(i)-XGrid).^2 + (Y_trx(i)-YGrid).^2));
    end
    
    out = out / possibleLocationCnt;
%     
%     minval = min(min(d_err_arr));
%     [r,c,v] = find(d_err_arr==minval);
%     
%     foundXS = XGrid(c,c);
%     foundYS = YGrid(r,r);
%     
%     out = 10*log10(pu_txPower) - channel.ploss_corr - 10*channel.ploss_exp*log10((0.0+(foundXS-XGrid).^2) + (0.0+(foundYS-YGrid).^2));
%     
    
end

