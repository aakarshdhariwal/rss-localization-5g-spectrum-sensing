 function [ out ] = estimate_power(XGrid, YGrid, XSens, YSens, sensor_measurement_arr, est_type )

grid_sz = size(XGrid);

if (strcmp(est_type,'IDW1') == 1)
    out = estimate_idw1(XGrid, YGrid, XSens, YSens, sensor_measurement_arr);
    
elseif (strcmp(est_type,'IDW2') == 1)
    out = estimate_idw2(XGrid, YGrid, XSens, YSens, sensor_measurement_arr);
    
elseif (strcmp(est_type,'KRIG') == 1)
    out = estimate_krig(XGrid, YGrid, XSens, YSens, sensor_measurement_arr);
    
else
    out = zeros(grid_sz);
end



end



function [out] = estimate_krig(XGrid, YGrid, XSens, YSens, sensor_measurement_arr)
    sensor_sz = size(XSens);
    num_sensor = sensor_sz(1)*sensor_sz(2);

    v = variogram([reshape(XSens,num_sensor,1) reshape(YSens,num_sensor,1)], reshape(sensor_measurement_arr,num_sensor,1),'maxdist',max(max(XGrid)));
    [dum,dum,dum,vstruct] = variogramfit(v.distance,v.val,[],[],[],'model','stable', 'plotit', false);
    [out,Zvar] = kriging(vstruct, reshape(XSens,num_sensor,1), reshape(YSens,num_sensor,1), reshape(sensor_measurement_arr,num_sensor,1),XGrid,YGrid); 
    
end

function [out] = estimate_idw2(XGrid, YGrid, XSens, YSens, sensor_measurement_arr)
    % Estimates power according to IDW2
    sensor_sz = size(XSens);
    grid_sz = size(XGrid);
    
    sum_invdist = zeros(grid_sz);
    for i=1:sensor_sz(1)
        for j=1:sensor_sz(2)
            sum_invdist = sum_invdist + ((XSens(i,j)-XGrid).^2 + (YSens(i,j)-YGrid).^2).^-1;
        end
    end
    
    out = zeros(grid_sz);
    for i=1:grid_sz(1)
        for j=1:grid_sz(2)
            sens_invdist = ((XSens-XGrid(i,j)).^2 + (YSens-YGrid(i,j)).^2).^-1;
            out(i,j) = sum(sum( (1/sum_invdist(i,j))*sens_invdist.* sensor_measurement_arr ));
        end
    end
end

function [out] = estimate_idw1(XGrid, YGrid, XSens, YSens, sensor_measurement_arr)
    % Estimates power according to IDW1
    sensor_sz = size(XSens);
    grid_sz = size(XGrid);

    sum_invdist = zeros(grid_sz);
    for i=1:sensor_sz(1)
        for j=1:sensor_sz(2)
            sum_invdist = sum_invdist + ((XSens(i,j)-XGrid).^2 + (YSens(i,j)-YGrid).^2).^-0.5;
        end
    end
    
    out = zeros(grid_sz);
    for i=1:grid_sz(1)
        for j=1:grid_sz(2)
            sens_invdist = ((XSens-XGrid(i,j)).^2 + (YSens-YGrid(i,j)).^2).^-0.5;
            out(i,j) = sum(sum( (1/sum_invdist(i,j))*sens_invdist.* sensor_measurement_arr ));
        end
    end
end



