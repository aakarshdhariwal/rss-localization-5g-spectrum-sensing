nPUs = 1; % Number of primary users
nSUs = 2; % Number of secondary users
nSamps = 1e3; % Number of sensing samples per sensing period
snrdB = linspace(-12,-8,nSUs); snr = db2pow(snrdB); % Signal-to-noise ratio (SNR) of each SU
sPow = ones(1,nSUs); % Received PU signal power at each SU
nPow = sPow./snr; % Noise power at each SU
nMCEvents = 5e3; % Number of Monte Carlo events
nROCPts = 50; % Number of receiver operating characteristic (ROC) curve points
Ted = zeros(nMCEvents,1); % Preallocating for speed
TX = randi([0,1],nMCEvents,1); % Simulates hypotheses H0 and H1 for the received signal, 50% under H0 and 50% under H1
for i = 1:nMCEvents
    H = sqrt(1/2)*complex(randn(nSUs,nPUs),randn(nSUs,nPUs)); % Rayleigh channel samples for each SU
    X = sqrt(1/nPUs)*complex(randn(nPUs,nSamps),randn(nPUs,nSamps)); % Normally distributed primary user signal (weighted by sqrt(1/nPUs) for keeping desired SNR)
    V = sqrt(diag(nPow)/2)*complex(randn(nSUs,nSamps),randn(nSUs,nSamps)); % AWGN
    Y = TX(i)*sqrt(diag(sPow)/2)*(H*X) + V; % Received signal at each SU
    Ted(i) = (1/nSUs)*sum((1/nSamps)*sum(abs(Y).^2,2)); % Energy detection test statistic
end
Thres = linspace(min(Ted),0.85*max(Ted),nROCPts); % Threshold decision for each ROC point
nH0 = sum(TX==0); % The number of times the PU transmitter(s) has been in the non-active state
nH1 = sum(TX==1); % The number of times the PU transmitter(s) has been in the active state
Pfa = sum(Ted>Thres&TX==0)/nH0; % Probability of false alarm for each decision threshold
Pd = sum(Ted>Thres&TX==1)/nH1; % Probability of detection for each decision threshold
figure
plot(Pfa,Pd)
title('ROC curve')
xlabel('Probability of false alrm')
ylabel('Probability of detection')
legend('ED','Location','SouthEast')
grid