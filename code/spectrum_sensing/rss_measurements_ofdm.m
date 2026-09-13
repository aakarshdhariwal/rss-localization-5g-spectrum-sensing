function rss_true=rss_measurements_ofdm(ofdm_tx_signal,ofdm_parameters,path_loss_exp,d_0,d_true)

% Generating rss values to run iteration over the adaptive algorithm for comparison.

% To add log normal shadowing or correlated shadowing to the path loss.
NumberofSamples = 1e0;
rss_samples = zeros(size(d_true,1),ofdm_parameters.subcarriers,NumberofSamples);

noise_std_dev = 8; 

f = 3.7e9;
c = 3e8;
wavelength = c/f;
contsant = (wavelength/(4*pi*d_0));
% Calculate true RSS values
for i = 1:size(d_true,1)
    for k = 1:size(ofdm_tx_signal,1)
        for j = 1:NumberofSamples
            % interpretation of log normal shadowing as gaussian noise.
            shadowing = normrnd(2, noise_std_dev);  
            rss_samples(i,k,j) = ofdm_tx_signal(k,:) - 10*path_loss_exp*log10(d_true(i)/d_0) + 20*log10(contsant) + shadowing; 
        end
    end
end

ofdm_channel_signal = mean(rss_samples,3);

%[ofdm_rx_signal,rx_pilots] = ofdm_rx_demod(ofdm_channel_signal',ofdm_parameters);
%[ofdm_rx_signal] = ofdm_rx_demod(ofdm_channel_signal',ofdm_parameters);
% pilots are N_pilot = length of pilotIndx, Nsym = number of ofdm symbols
% pilots are N_pilot = length of pilotIndx, Nsym = number of ofdm symbols
% per antenna and Nr = number of antenna.

rx_pilots = ofdm_channel_signal(:,ofdm_parameters.pilots);
% rx_pilots = reshape(rx_pilots,size(rx_pilots,3),size(rx_pilots,2),size(rx_pilots,1));
%rss_true = reshape(mean(real(rx_pilots),2),size(d_true,1),1);

rss_true = reshape(mean(real(ofdm_channel_signal),2),size(d_true,1),1);

end

function [ofdm_rx_signal] = ofdm_rx_demod(ofdm_channel_signal,ofdm_parameters)

% [ofdm_rx_signal,rx_pilots] = ofdmdemod(ofdm_channel_signal,ofdm_parameters.subcarriers,ofdm_parameters.cyclic_prefix, ...
    % ofdm_parameters.cyclic_prefix,ofdm_parameters.nullind,ofdm_parameters.pilots);

[ofdm_rx_signal] = ofdmdemod(ofdm_channel_signal,ofdm_parameters.subcarriers,ofdm_parameters.cyclic_prefix);
end