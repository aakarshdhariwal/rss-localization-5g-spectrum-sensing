function rss_true=rss_measurements(tx_power,rx,path_loss_exp,d_0,d_true)

% Generating rss values to run iteration over the adaptive algorithm for comparison.
 
% To add log normal shadowing or correlated shadowing to the path loss.
NumberofSamples = 100;
f = 3.7e9;
c = 3e8;
wavelength = c/f;
contsant = (wavelength/(4*pi*d_0));
% rss_samples for iid shadowing
%rss_samples = zeros(size(d_true,1),NumberofSamples);

% rss for correlated shadowing
rss_samples = [];
noise_std_dev = 8; 
path_loss = tx_power - 10*path_loss_exp*log10(d_true/d_0) + 20*log10(contsant);

co_variance = correlated_shadowing_co_var(noise_std_dev,rx);

%Calculate true RSS values
% for i = 1:size(d_true,1)
%     for j = 1:NumberofSamples
%         % interpretation of log normal shadowing as gaussian noise.
% 
%         gaussian_noise = normrnd(0, noise_std_dev);  
%         rss_samples(i,j) = tx_power - 10*path_loss_exp*log10(d_true(i)/d_0) + 20*log10(contsant) +  gaussian_noise; 
%     end
% end

for j = 1:NumberofSamples
        % interpretation of log normal shadowing as gaussian noise.
        shadowing = mvnrnd(zeros(size(rx,1),1),co_variance)';

        rss_samples(:,j) = path_loss + shadowing;
end

rss_true = mean(rss_samples,2);

end

function co_variance = correlated_shadowing_co_var(noise_std_dev,rx)

d_corr = 8; % in meters
co_variance = zeros(size(rx,1),size(rx,1));

for i = 1:size(rx,1)
    for j = 1:size(rx,1)
    d = pdist2(rx(i,:),rx(j,:));
    co_variance(i,j) = (noise_std_dev^2)*exp(-d/d_corr);
    end
end

% tf = issymmetric(co_var);
% lambda = eig(co_var);
% tol = length(lambda )*eps(max(lambda ));
% isposdef = all(lambda  > tol);
% issemidef = all(lambda  > -tol);

end
