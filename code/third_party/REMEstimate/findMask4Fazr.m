function [ mask ] = findMask4Fazr(Grid_real_mask, estimate_arr, fazr)
    precision = 0.00007;
    maxValue = max(max(max(estimate_arr)));
    
    step = 2;
    threshold = maxValue;
    while(step > precision)
        Grid_try_mask = estimate_arr > threshold;
        fazr_try = nnz(Grid_try_mask & ~Grid_real_mask)/nnz(~Grid_real_mask);
        
        if (fazr_try < fazr)
            threshold = threshold - step;
        else
            threshold = threshold + step;
            step = step / 3;
            threshold = threshold - step;
        end
    end
    
    mask = estimate_arr > threshold;
end