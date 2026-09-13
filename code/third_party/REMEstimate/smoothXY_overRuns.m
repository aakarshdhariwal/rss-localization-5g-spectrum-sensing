function [ output ] = smoothXY_overRuns(inp)

sz_inp = size(inp);

output = sum(inp, 3);

output = output / sz_inp(3);

end

