function [ output ] = eval_dist2locations( px, py, LocXs, LocYs )

output = sqrt((LocXs-px).^2 + (LocYs-py).^2);

end

