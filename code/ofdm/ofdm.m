%% OFDM waveform generation using mu =0 numerology. 
% this consists of 1 frame of length 10 ms. Each frame has 10 subframes or
% 10 slots of length 1 ms each. Each subframe has 14 ofdm symbols. Carrier
% frequency of 2.5GHz with subcarrier spacing of 15KHz, 1 resource
% block = number of OFDM symbols x number of subcarriers. 1 Resurce Block
% consists of 12 (180 KHz frequency bandwidth)subcarriers and 14 OFDM symbols for Numerology 0. 

%% ofdm wave
function [ofdm_tx_signal,ofdm_parameters] = ofdm(M,nfft,cplen,nSym)
    % M = 4;     % Modulation order
    % nfft = 128;  % FFT length
    % cplen = 16; % Cyclic prefix length
    % nSym  = 1; % Number of symbols per RE
    ofdm_parameters.modulation = M;
    ofdm_parameters.subcarriers = nfft;
    ofdm_parameters.cyclic_prefix = cplen;
    ofdm_parameters.symbols = nSym;

    nullIdx  = [1:6 33 ]';
    pilotIdx = [12 26 40 54]';
    
    ofdm_parameters.nullind = nullIdx;
    ofdm_parameters.pilots = pilotIdx;

    numDataCarrs = nfft -length(pilotIdx) - length(nullIdx);
    dataSym = randi([0 M-1],numDataCarrs,nSym);
    qamSig = qammod(dataSym,M,UnitAveragePower=true);
    %pilots = repmat(pskmod((0:3).',4),1,nSym);
    pilots = repmat([1+1i;1+1i;1+1i;1+1i],1,nSym);
    ofdm_tx_signal = ofdmmod(qamSig,nfft,cplen,nullIdx,pilotIdx,pilots);
    figure;
    plot(abs(ofdm_tx_signal));
    title("OFDM Waveform");
end


