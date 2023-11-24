% Parameters

g = 9.81;           % Acceleration due to gravity (m/s^2)
rho_water = 1000;   % Density of water (kg/m^3)
h_water = 10;       % Height of water column (m)
diameter_pipe = 0.1;% Diameter of the pipe (m)
radius_pipe = diameter_pipe / 2;

% Motor parameters
motor_efficiency = 0.8;     % Motor efficiency
motor_torque_constant = 0.1; % Motor torque constant (Nm/A)
motor_voltage = 12;          % Motor voltage (V)

% Simulation parameters
time_span = 0:0.1:60;        % Simulation time span (s)
initial_speed = 0;           % Initial speed of the motor

% Initialize variables
speed = zeros(size(time_span));
torque = zeros(size(time_span));

% Simulation loop
for i = 1:length(time_span)-1
    % Calculate water height at the current time
    water_height = h_water - speed(i) * time_span(i);
    
    % Calculate gravitational force on the water column
    gravitational_force = rho_water * g * pi * radius_pipe^2 * water_height;
    
    % Calculate torque required to lift water
    required_torque = gravitational_force * radius_pipe;
    
    % After 30 seconds, set a constant torque
    if time_span(i) >= 30
        required_torque = 5; % Set your desired constant torque value
    end
    
    % Calculate current draw from the motor
    current_draw = required_torque / (motor_torque_constant * motor_efficiency);
    
    % Calculate torque provided by the motor
    torque(i) = current_draw * motor_torque_constant * motor_efficiency;
    
    % Update motor speed based on torque and voltage
    acceleration = (torque(i) / radius_pipe) * (1 / motor_efficiency);
    speed(i + 1) = speed(i) + acceleration * 0.1;
    
    % Ensure speed does not go negative
    if speed(i + 1) < 0
        speed(i + 1) = 0;
    end
end

% Plot results
figure;

subplot(2, 1, 1);
plot(time_span, torque, 'b-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Torque (Nm)');
title('Torque vs Time');

subplot(2, 1, 2);
plot(time_span(1:end-1), speed(1:end-1), 'r-', 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Motor Speed (rad/s)');
title('Motor Speed vs Time');

% Adjust plot settings
grid on;