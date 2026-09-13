%% load
live4 = load("localisation_using_4_sensors.mat");
live4 = live4.localisation_error_fmin;

live8 = load("localisation_using_8_sensors.mat");
live8 = live8.localisation_error_fmin;

live10 = load("localisation_using_10_sensors.mat");
live10 = live10.localisation_error_fmin;

%% plot 

figure;
plot((1/size(live4,2))*live4);
hold on;
plot((1/size(live4,2))*live8);
plot((1/size(live4,2))*live10);
% hold off;
xlabel('Number of receivers');
ylabel('Localisation Error');
legend('LIvE 4 Sensors','LIvE 8 Sensors','LIvE 10 Sensors'); %,'LSQnonlin-LIvE Algorithm');
title("Localisation Error");