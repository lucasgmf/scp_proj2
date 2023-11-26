% Solar Irradiation Schematic with Smoothed Trapezoidal Profile


clear;
close all;
clc;


% Define time (in hours)
time = 0:0.1:24; % Assuming data for 24 hours with a resolution of 0.1 hours

%% Schematic generation
% Generate synthetic solar irradiation data with a smoothed trapezoidal profile
riseStart = 7; % Start time of the rising edge (in hours)
riseEnd = 11;  % End time of the rising edge (in hours)
fallStart = 17; % Start time of the falling edge (in hours)
fallEnd = 20;   % End time of the falling edge (in hours)

maxValue = 10;

% Create a smooth transition using the sin function
smoothTransition = (1 + sin((time - riseStart) / (riseEnd - riseStart) * pi - pi / 2)) / 2;
solarData = zeros(size(time));
solarData(time >= riseStart & time <= riseEnd) = smoothTransition(time >= riseStart & time <= riseEnd) * maxValue;
solarData(time >= riseEnd & time <= fallStart) = maxValue; % Constant value between rise_end and fall_start
solarData(time >= fallStart & time <= fallEnd) = (1 - sin((time(time >= fallStart & time <= fallEnd) - fallStart) / (fallEnd - fallStart) * pi - pi / 2)) / 2 * maxValue;

% Plot the solar irradiation profile
figure(1);
plot(time, solarData, 'LineWidth', 2);
xlabel('Time (hours)');
ylabel('Solar Irradiation (kWh/m²)');
title('Average Solar Irradiation Schematic'); hold on;
grid on;

% Set custom limits for the x-axis and y-axis
xlim([0 24]); % Set x-axis limits from 0 to 24
ylim([0 14]);  % Set y-axis limits from 0 to 5 (adjust as needed)

% Display the average solar irradiation
disp(['Actual average solar irradiation: ', num2str(trapz(time, solarData) / 24), ' kWh/m² per day']);

% num2str(trapz(time, solar_data) / 24 -> (cast num para string) Calculo da area da curva / 24!

% Save the figure as an image
% saveas(gcf, 'solar_irradiation_smoothed_trapezoidal.png');

%% PV parameters

PVdata = zeros(size(time));

PVdata = min(solarData,2.8); % limit to 2.8 kW and update PVdata

plot(time, PVdata, 'LineWidth',2);

PVperfomance = 0.15;

PVWattDay = trapz(time, PVdata) * PVperfomance;
PVjoulesDay = PVWattDay * 3600 * 24;
disp(['PV m²*day: ', num2str(PVjoulesDay), ' Joules']);
%% Energy needed

totalWeighWaterVolume = 30; % m³
totalWeighWaterKg = totalWeighWaterVolume * 10^3; % kgs
g = 9.81; % m/s^2
height = 20; % m

bombPerfomance = 1; % Still need to be dimensioned

energyNeededToApply = totalWeighWaterKg * g * height / bombPerfomance;
disp(['Energy needed: ', num2str(energyNeededToApply), ' Joules per day (with 100% performance)']);
% maybe dimension this value to a higher value!!!!
%% Getting area of PV 

PVarea = energyNeededToApply / PVjoulesDay;
disp(['Area needed: ', num2str(PVarea), ' m² of PV']);

%% Torque control

% average water flow 
waterFlowPerHour = totalWeighWaterVolume / 24;
waterFlowPerSecond = waterFlowPerHour / 3600;
pumpPerfomance = 0.8;

waterDens = 997; % kg/m³

motorSpeedRPM = 3000;
motorSpeedRadS = (motorSpeedRPM * 2 * pi) / 60;

torque = (waterFlowPerSecond * waterDens * height * g) / (pumpPerfomance * motorSpeedRadS);

% Power in engine shaft
powerEngineShaft = torque * motorSpeedRadS; % Watts

% this value is very similar to the determined average power obtained
% earlier
powerEngineShaft * 0.8;

%% Load in the pump
%! Not 
% necessary time from motor off to nominal
startingTimeNominal = 5; 

timeLimitLoadSignal = 30; % end simulation

% generate signal to simulate the motor load
signalTime = 0:.1:timeLimitLoadSignal;

% smooth transition
riseStart = 0;
riseEnd = startingTimeNominal;


% Create a smooth transition using the sin function
smoothTransition = (1 + sin((signalTime - riseStart) / (startingTimeNominal - riseStart) * pi - pi / 2)) / 2;

% Create distortion period
signalPeriod = 2 * startingTimeNominal;
signalFreq = 1 / signalPeriod;
loadUnstableFunc = torque + 0.025 * torque * sin(2*pi*signalFreq*signalTime);

loadSignalData = zeros(size(signalTime));

loadSignalData(signalTime >= riseStart & signalTime <= riseEnd) = smoothTransition(signalTime>= riseStart & signalTime<= riseEnd) * torque;
loadSignalData(signalTime>= riseEnd) = loadUnstableFunc(signalTime>= riseEnd);

% Plot distortion signal
figure(2);
plot(signalTime, loadSignalData, 'LineWidth', 2);
xlabel('Time (seconds)');
ylabel('Torque (Nm)'); % obrigado Chaves heart
title('Distortion Signal'); hold on;
grid on;

% Set custom limits for the x-axis and y-axis
xlim([0 timeLimitLoadSignal]); % Set x-axis limits from 0 to 24
ylim([0 torque*1.1]);  % Set y-axis limits from 0 to 5 (adjust as needed)
