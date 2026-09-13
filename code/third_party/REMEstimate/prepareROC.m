function [ roc ] = prepareROC( measurement_arr_grid, estimate_arr , fazr_arr, realThreshold)

sz = size(fazr_arr);
roc.cdzr = zeros(sz);
roc.mdzr = zeros(sz);
roc.fazr = fazr_arr;

Grid_real_mask = measurement_arr_grid > realThreshold;
    
i=1;
for fazr = fazr_arr
    % find slack for fazr
    Grid_esti_mask = findMask4Fazr(Grid_real_mask, estimate_arr, fazr);
    
    CDZR = nnz(Grid_esti_mask & Grid_real_mask)/nnz(Grid_real_mask);
    MDZR = nnz(~Grid_esti_mask & Grid_real_mask)/nnz(Grid_real_mask);
    
    roc.cdzr(i) = CDZR;
    roc.mdzr(i) = MDZR;
    
    i = i+1;
end

end




