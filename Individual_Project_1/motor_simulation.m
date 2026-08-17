% ====================================================================
% Script: Unit-Step Response - DC Motor
% Transfer function: G(s) = K_M / (tau*s + 1)
% Student: Kevin Joseph Berrocal Rodríguez
% Student ID: 2020113094
% Course: Automatic Control
%
% This script calculates the first-order model of a DC motor from
% its physical parameters, obtains K_M and tau, and generates the
% time-domain response to a unit-step input.
%
% The input parameters are entered directly through the Octave terminal.
%
% Model:
%   K_M = Kt / (Ra*b + Kt*Kb)
%   tau = Ra*J / (Ra*b + Kt*Kb)
% ====================================================================

clear;
clc;
close all;

%% Parameter input function
function value = read_parameter(prompt)

    while true

        user_input = input(prompt, 's');

        % Check for empty input.
        if isempty(strtrim(user_input))
            fprintf('Warning: input cannot be empty. Please enter a value.\n');
            continue;
        end

        % Convert the input text to a number.
        value = str2double(user_input);

        % Check for invalid or non-numeric input.
        if isnan(value) || ~isfinite(value)
            fprintf('Warning: please enter a valid numeric value.\n');
            continue;
        end

        break;
    end

end

%% Input parameters
fprintf('DC Motor First-Order Model\n');
fprintf('===========================\n');
fprintf('Enter the motor parameters:\n\n');

Kt = read_parameter('Kt - Torque constant [N*m/A]: ');
Ra = read_parameter('Ra - Armature resistance [Ohm]: ');
b  = read_parameter('b  - Viscous friction coefficient [N*m*s/rad]: ');
Kb = read_parameter('Kb - Back-EMF constant [V*s/rad]: ');
J  = read_parameter('J  - Motor and load inertia [kg*m^2]: ');

%% Input validation
% Check that all values are real, finite and physically valid.
parameters = [Kt, Ra, b, Kb, J];

if any(~isfinite(parameters)) || any(~isreal(parameters))
    error('All parameters must be finite real numbers.');
end

if Kt <= 0
    error('Kt must be greater than zero.');
end

if Ra <= 0
    error('Ra must be greater than zero.');
end

if b < 0
    error('b must be greater than or equal to zero.');
end

if Kb <= 0
    error('Kb must be greater than zero.');
end

if J <= 0
    error('J must be greater than zero.');
end

%% Calculate motor model
% Obtain the gain and time constant from the motor parameters.
model_denominator = Ra*b + Kt*Kb;

if model_denominator <= 0 || ~isfinite(model_denominator)
    error('The calculated denominator is not physically valid.');
end

KM = Kt / model_denominator;
tau = (Ra*J) / model_denominator;

if ~isfinite(KM) || ~isfinite(tau) || tau <= 0
    error('The calculated K_M and tau values are not valid.');
end

%% Display model parameters
fprintf('\nCalculated model parameters\n');
fprintf('===========================\n');
fprintf('K_M = %.8g\n', KM);
fprintf('tau = %.8g s\n', tau);

fprintf('\nTransfer function:\n');
fprintf('G(s) = %.8g / (%.8g*s + 1)\n', KM, tau);

%% Unit-step simulation
% The input is explicitly defined as a unit step with amplitude 1.
input_step = 1;

% Simulate long enough to observe the complete transient response.
five_tau = 5*tau;
settling_time_2pct = -tau*log(0.02);

simulation_end_time = max(five_tau, settling_time_2pct) * 1.10;

time = linspace(0, simulation_end_time, 1000);

% First-order motor response to the unit-step input.
response = input_step * KM * (1 - exp(-time/tau));

% Reference signal: unit step with amplitude 1.
reference = input_step * ones(size(time));

%% Characteristic values
final_value = input_step * KM;
response_at_tau = final_value * (1 - exp(-1));
response_at_five_tau = final_value * (1 - exp(-5));

% Difference between the unit-step reference and final output.
steady_state_error = abs(input_step - final_value);

response_at_settling = final_value * ...
    (1 - exp(-settling_time_2pct/tau));

%% Display simulation results
fprintf('\nSimulation results\n');
fprintf('==================\n');
fprintf('Input step                         = %.4g\n', input_step);
fprintf('Final expected value, y(infinity)  = %.8g\n', final_value);
fprintf('Response at t = tau                = %.8g\n', response_at_tau);
fprintf('Response at t = 5*tau              = %.8g\n', response_at_five_tau);
fprintf('2%% settling time                   = %.8g s\n', ...
        settling_time_2pct);
fprintf('Steady-state error                 = %.8g\n', ...
        steady_state_error);

%% Plot
figure('Name', 'DC Motor Unit-Step Response', ...
       'NumberTitle', 'off');

% Motor response.
plot(time, response, 'b-', 'LineWidth', 2);
hold on;
grid on;

% Unit-step reference.
plot(time, reference, 'k--', 'LineWidth', 1.5);

% Final motor value.
plot([0, simulation_end_time], ...
     [final_value, final_value], ...
     'm:', 'LineWidth', 1.2);

% 2% settling limits around the final value.
upper_settling_limit = final_value * 1.02;
lower_settling_limit = final_value * 0.98;

plot([0, simulation_end_time], ...
     [upper_settling_limit, upper_settling_limit], ...
     'r:', 'LineWidth', 1.0);

plot([0, simulation_end_time], ...
     [lower_settling_limit, lower_settling_limit], ...
     'r:', 'LineWidth', 1.0);

% Characteristic points.
plot(tau, response_at_tau, ...
     'ko', 'MarkerSize', 7, 'MarkerFaceColor', 'k');

plot(five_tau, response_at_five_tau, ...
     'mo', 'MarkerSize', 7, 'MarkerFaceColor', 'm');

plot(settling_time_2pct, response_at_settling, ...
     'gs', 'MarkerSize', 7, 'MarkerFaceColor', 'g');

% Display steady-state error when it is meaningful.
if steady_state_error > 1e-4

    x_error = simulation_end_time * 0.82;

    plot([x_error, x_error], ...
         [final_value, input_step], ...
         'c-', 'LineWidth', 1.5);

    text(x_error, ...
         (final_value + input_step)/2, ...
         sprintf('e_{ss} = %.4g', steady_state_error), ...
         'VerticalAlignment', 'middle');
end

% Labels for characteristic points.
text(tau, ...
     response_at_tau, ...
     sprintf('  t = tau, y = %.4g', response_at_tau), ...
     'VerticalAlignment', 'bottom');

text(five_tau, ...
     response_at_five_tau, ...
     sprintf('  t = 5tau, y = %.4g', response_at_five_tau), ...
     'VerticalAlignment', 'top');

text(settling_time_2pct, ...
     response_at_settling, ...
     sprintf('  t_s(2%%) = %.4g s', settling_time_2pct), ...
     'VerticalAlignment', 'bottom');

xlabel('Time [s]');
ylabel('Output');

title('DC Motor Response to a Unit-Step Input');

legend({'Motor response', ...
        'Unit-step reference', ...
        'Final value', ...
        '2% upper limit', ...
        '2% lower limit', ...
        't = tau', ...
        't = 5tau', ...
        '2% settling time'}, ...
       'Location', 'southeast');

hold off;

fprintf('\nSimulation completed successfully.\n');
