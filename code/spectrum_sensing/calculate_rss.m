function rss_mes = calculate_rss(ofdm_tx_signal,path_loss_exp,d_0,d_true)

ploss_corr =  10*path_loss_exp*log10(d_0); %dBm
TW = 10;
sigma = 8;
grid_mean_powr_arr = zeros(size(d_true,1),size(ofdm_tx_signal,1));
rss_mes = zeros(size(grid_mean_powr_arr));
for i = 1:size(d_true,1)
    grid_mean_powr_arr(i,:) = ofdm_tx_signal' + ploss_corr - 10*path_loss_exp*log10(d_true(i)); 
    rss_mes(i,:) =  normrnd(grid_mean_powr_arr(i,:), sigma/TW^0.5);
end
rss_mes = real(mean(rss_mes,2));
end


function noise = correlated_shadowing(noise_std_dev,rx)

d_corr = 5; %in meters
co_var = zeros(size(rx,1),size(rx,1));

for i = 1:size(rx,1)
    for j = 1:size(rx,1)
    d = pdist2(rx(i,:),rx(j,:));
    co_var(i,j) = noise_std_dev*exp(-d/d_corr);
    end
end

% tf = issymmetric(co_var);
% lambda = eig(co_var);
% tol = length(lambda )*eps(max(lambda ));
% isposdef = all(lambda  > tol);
% issemidef = all(lambda  > -tol);
noise = mvnrnd(zeros(size(rx,1),1),co_var);
end