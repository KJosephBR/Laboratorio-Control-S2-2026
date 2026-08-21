% ====================================================================
% Script: Routh-Hurwitz and Root Locus Simulation
% Transfer function: G(s) defined by its open-loop poles and zeros
% Student: Kevin Joseph Berrocal Rodríguez
% Student ID: 2020113094
% Course: Automatic Control Lab
%
% This script analyzes a plant G(s) using its open-loop poles and zeros.
% For a selected feedback gain K, it builds the closed-loop
% characteristic equation, generates the Routh-Hurwitz table,
% evaluates system stability, and plots the Root Locus.
%
% The input poles, zeros, and gain K are entered directly through
% the Octave terminal.
%
% Closed-loop characteristic equation:
%   1 + K*G(s) = 0
%
% The Routh-Hurwitz table is constructed from the coefficients of
% the resulting characteristic equation.
% ====================================================================

function routh_root_locus()

    clear;
    clc;
    close all;

    %% Load required package
    try
        pkg load control;
    catch
        error(['The Octave Control package is required. ' ...
               'Install it with: pkg install -forge control']);
    end

    fprintf('===============================================\n');
    fprintf(' Routh-Hurwitz and Root Locus Simulation\n');
    fprintf('===============================================\n\n');

    %% User input: open-loop poles and zeros
    fprintf('Enter poles and zeros of G(s).\n');
    fprintf('Examples:\n');
    fprintf('  Real values:       -1 -2 -3\n');
    fprintf('  Complex pair:      -1+2i -1-2i\n');
    fprintf('  No zeros:          []\n\n');

    zeros_plant = read_complex_vector('Open-loop zeros: ');
    poles_plant = read_complex_vector('Open-loop poles: ');

    if isempty(poles_plant)

        error('At least one open-loop pole is required.');

    end

    % The plant must be proper.
    if length(zeros_plant) > length(poles_plant)

        error(['The plant is improper: number of zeros cannot ' ...
               'exceed number of poles.']);

    end

    %% User input: feedback gain
    fprintf('\nThe Root Locus corresponds to varying K >= 0.\n');

    gain_K = read_nonnegative_scalar( ...
        'Select K for the Routh-Hurwitz analysis: ');

    %% Build G(s) from poles and zeros
    numerator = poly(zeros_plant);
    denominator = poly(poles_plant);

    % Normalize the denominator.
    denominator = denominator / denominator(1);

    G = tf(numerator, denominator);

    fprintf('\nOpen-loop transfer function G(s):\n');
    disp(G);

    %% Build the closed-loop characteristic equation
    %
    % G(s) = N(s) / D(s)
    %
    % 1 + K*G(s) = 0
    %
    % Therefore:
    %
    % D(s) + K*N(s) = 0

    order_difference = ...
        length(denominator) - length(numerator);

    % Pad numerator with leading zeros to match denominator length.
    numerator_padded = ...
        [zeros(1, order_difference), numerator];

    characteristic_coeffs = ...
        denominator + gain_K * numerator_padded;

    fprintf('\nClosed-loop characteristic equation for K = %.6g:\n', ...
            gain_K);

    fprintf('%s = 0\n', ...
            polynomial_to_string(characteristic_coeffs));

    %% Build the Routh-Hurwitz table
    [routh_table, special_case] = ...
        build_routh_table(characteristic_coeffs);

    fprintf('\nRouth-Hurwitz table:\n');
    display_routh_table(routh_table);

    if special_case

        fprintf(['\nNote: The Routh table required a special-case ' ...
                 'correction (zero first element or complete row ' ...
                 'of zeros).\n']);

    end

    %% Determine stability using the first column
    first_column = routh_table(:, 1);

    % Ignore very small numerical values.
    sign_tolerance = 1e-9;

    first_column(abs(first_column) < sign_tolerance) = 0;

    sign_changes = count_sign_changes(first_column);

    fprintf('\nRouth-Hurwitz result:\n');

    if all(first_column > 0)

        fprintf('  No sign changes were found in the first column.\n');
        fprintf('  The selected closed-loop system is STABLE.\n');

    elseif any(first_column < 0)

        fprintf('  Sign changes were found in the first column: %d\n', ...
                sign_changes);

        fprintf('  The selected closed-loop system is UNSTABLE.\n');

    else

        fprintf('  The first column contains zero values.\n');

        fprintf(['  The selected system is MARGINALLY STABLE / ' ...
                 'CRITICAL.\n']);

    end

    %% Calculate closed-loop poles
    closed_loop_poles = roots(characteristic_coeffs);

    fprintf('\nClosed-loop poles for K = %.6g:\n', gain_K);
    disp(closed_loop_poles);

    %% Numerical stability verification
    pole_tolerance = 1e-8;

    if all(real(closed_loop_poles) < -pole_tolerance)

        fprintf('Numerical pole check:\n');
        fprintf('  All closed-loop poles have negative real parts.\n');
        fprintf('  Result: STABLE.\n');

    elseif any(real(closed_loop_poles) > pole_tolerance)

        fprintf('Numerical pole check:\n');
        fprintf('  At least one closed-loop pole has a positive real part.\n');
        fprintf('  Result: UNSTABLE.\n');

    else

        fprintf('Numerical pole check:\n');
        fprintf(['  At least one pole is on or very close to the ' ...
                 'imaginary axis.\n']);

        fprintf('  Result: MARGINALLY STABLE / CRITICAL.\n');

    end

    %% Generate Root Locus
    figure('Name', 'Root Locus', ...
           'NumberTitle', 'off');

    % Generate the Root Locus.
    rlocus(G);
    grid on;
    hold on;

    %% Define plot colors

    % Root locus.
    root_locus_color = [0 0.45 0.95];

    % Asymptotes.
    asymptote_color = [0.20 0.20 0.20];

    % Open-loop poles.
    pole_color = [0.85 0.10 0.10];

    % Open-loop zeros.
    zero_color = [0.10 0.60 0.20];

    % Closed-loop poles.
    closed_pole_color = [0.60 0.10 0.75];

    %% Mark open-loop poles

    if ~isempty(poles_plant)

        plot(real(poles_plant), ...
             imag(poles_plant), ...
             'x', ...
             'Color', pole_color, ...
             'MarkerSize', 10, ...
             'LineWidth', 2);

    end

    %% Mark open-loop zeros

    if ~isempty(zeros_plant)

        plot(real(zeros_plant), ...
             imag(zeros_plant), ...
             'o', ...
             'Color', zero_color, ...
             'MarkerSize', 9, ...
             'LineWidth', 2);

    end

    %% Mark closed-loop poles for selected K

    plot(real(closed_loop_poles), ...
         imag(closed_loop_poles), ...
         's', ...
         'Color', closed_pole_color, ...
         'MarkerSize', 8, ...
         'LineWidth', 2);

    %% Axis labels and title

    xlabel('Real Axis');
    ylabel('Imaginary Axis');

    title(sprintf('Root Locus of G(s) - Selected K = %.6g', ...
                  gain_K));

    %% Create independent legend handles

    % Root locus: continuous line.
    h_root_locus = plot(nan, nan, ...
                        '-', ...
                        'Color', root_locus_color, ...
                        'LineWidth', 2);

    % Asymptotes: dashed line.
    h_asymptotes = plot(nan, nan, ...
                        '--', ...
                        'Color', asymptote_color, ...
                        'LineWidth', 1.2);

    % Open-loop poles.
    h_poles = plot(nan, nan, ...
                   'x', ...
                   'Color', pole_color, ...
                   'MarkerSize', 10, ...
                   'LineWidth', 2);

    % Open-loop zeros.
    h_zeros = plot(nan, nan, ...
                   'o', ...
                   'Color', zero_color, ...
                   'MarkerSize', 9, ...
                   'LineWidth', 2);

    % Closed-loop poles.
    h_closed_poles = plot(nan, nan, ...
                          's', ...
                          'Color', closed_pole_color, ...
                          'MarkerSize', 8, ...
                          'LineWidth', 2);

    legend([h_root_locus, ...
            h_asymptotes, ...
            h_poles, ...
            h_zeros, ...
            h_closed_poles], ...
           {'Root locus (K >= 0)', ...
            'Root locus asymptotes', ...
            'Open-loop poles', ...
            'Open-loop zeros', ...
            'Closed-loop poles (selected K)'}, ...
           'Location', 'best');

    hold off;

    fprintf('\nRoot Locus generated successfully.\n');
    fprintf('  Continuous line = Root locus for K >= 0\n');
    fprintf('  Dashed line = Root locus asymptotes\n');
    fprintf('  X = Open-loop poles\n');
    fprintf('  O = Open-loop zeros\n');
    fprintf('  Square = Closed-loop poles for selected K\n');

end


%% ================================================================
%% Local Functions
%% ================================================================

function vector = read_complex_vector(prompt_text)

    while true

        user_text = strtrim(input(prompt_text, 's'));

        if isempty(user_text)

            fprintf(['Input cannot be empty. Enter values or [] ' ...
                     'if there are no zeros.\n']);

            continue;

        end

        % Allow [] to represent an empty vector.
        if strcmp(user_text, '[]')

            vector = [];

            return;

        end

        parsed_value = str2num(user_text); %#ok<ST2NM>

        if isempty(parsed_value)

            fprintf(['Invalid input. Use values such as: ' ...
                     '-1 -2 or -1+2i -1-2i\n']);

            continue;

        end

        if ~isvector(parsed_value)

            fprintf('Please enter a single row or column vector.\n');

            continue;

        end

        vector = parsed_value(:).';

        return;

    end

end


function scalar_value = read_nonnegative_scalar(prompt_text)

    while true

        user_text = strtrim(input(prompt_text, 's'));

        if isempty(user_text)

            fprintf('Input cannot be empty.\n');

            continue;

        end

        scalar_value = str2double(user_text);

        if isnan(scalar_value) || ...
           ~isreal(scalar_value) || ...
           ~isfinite(scalar_value)

            fprintf('Enter one finite real number.\n');

            continue;

        end

        if scalar_value < 0

            fprintf('K must be greater than or equal to zero.\n');

            continue;

        end

        return;

    end

end


function [R, special_case] = build_routh_table(coeffs)

    % Build the Routh-Hurwitz table from polynomial coefficients.
    %
    % The coefficients must be ordered from the highest power of s
    % to the constant term.

    coeffs = coeffs(:).';

    polynomial_order = length(coeffs) - 1;

    rows = polynomial_order + 1;

    columns = ceil((polynomial_order + 1) / 2);

    R = zeros(rows, columns);

    special_case = false;

    % First row.
    R(1, 1:length(coeffs(1:2:end))) = ...
        coeffs(1:2:end);

    % Second row.
    if length(coeffs) >= 2

        R(2, 1:length(coeffs(2:2:end))) = ...
            coeffs(2:2:end);

    end

    epsilon = 1e-9;

    for row = 3:rows

        %% Check for a complete row of zeros first.
        %
        % This check must occur before replacing a zero first element
        % with epsilon.

        if all(abs(R(row - 1, :)) < epsilon)

            special_case = true;

            previous_row = R(row - 2, :);

            represented_degree = ...
                polynomial_order - (row - 3);

            exponents = represented_degree:-2:0;

            replacement = zeros(1, columns);

            for column = 1:length(exponents)

                if exponents(column) > 0

                    replacement(column) = ...
                        previous_row(column) * exponents(column);

                end

            end

            R(row - 1, :) = replacement;

        end

        %% Avoid division by zero in the first element.

        if abs(R(row - 1, 1)) < epsilon

            R(row - 1, 1) = epsilon;

            special_case = true;

        end

        %% Calculate the current row.

        for column = 1:(columns - 1)

            R(row, column) = ...
                (R(row - 1, 1) * R(row - 2, column + 1) - ...
                 R(row - 2, 1) * R(row - 1, column + 1)) / ...
                 R(row - 1, 1);

        end

    end

end


function display_routh_table(R)

    [rows, columns] = size(R);

    fprintf('\n');

    for row = 1:rows

        degree_text = sprintf('s^%d', rows - row);

        fprintf('%-5s ', degree_text);

        for column = 1:columns

            fprintf('%12.6g ', R(row, column));

        end

        fprintf('\n');

    end

end


function changes = count_sign_changes(values)

    values = values(:);

    % Ignore values that are numerically zero.
    values = values(abs(values) > 1e-12);

    if length(values) < 2

        changes = 0;

        return;

    end

    changes = sum( ...
        sign(values(1:end-1)) ~= ...
        sign(values(2:end)));

end


function text = polynomial_to_string(coeffs)

    degree = length(coeffs) - 1;

    text = '';

    for k = 1:length(coeffs)

        coefficient = coeffs(k);

        current_power = degree - (k - 1);

        % Ignore coefficients that are essentially zero.
        if abs(coefficient) < 1e-12

            continue;

        end

        sign_value = sign(coefficient);

        absolute_value = abs(coefficient);

        if isempty(text)

            sign_text = '';

        elseif sign_value > 0

            sign_text = ' + ';

        else

            sign_text = ' - ';

        end

        % Constant term.
        if current_power == 0

            term_text = sprintf('%.6g', ...
                                absolute_value);

        % First-order term.
        elseif current_power == 1

            if abs(absolute_value - 1) < 1e-12

                term_text = 's';

            else

                term_text = sprintf('%.6g*s', ...
                                    absolute_value);

            end

        % Higher-order term.
        else

            if abs(absolute_value - 1) < 1e-12

                term_text = sprintf('s^%d', ...
                                    current_power);

            else

                term_text = sprintf('%.6g*s^%d', ...
                                    absolute_value, ...
                                    current_power);

            end

        end

        if isempty(text) && sign_value < 0

            text = ['- ' term_text];

        else

            text = [text sign_text term_text]; %#ok<AGROW>

        end

    end

    if isempty(text)

        text = '0';

    end

end
