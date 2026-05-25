% =========================================================================
% SCRIPT: interpolacion_impedancia.m
% OBJETIVO: Resolución completa de la Parte B - Interpolación
%           B1: Interpolación polinómica, fenómeno de Runge y validación LOO.
%           B2: Spline cúbico natural, comparación y evaluación a 1000 Hz.
% =========================================================================

clear; clc; close all;

% 1. Definición de los datos experimentales (30 puntos)
f = [100, 120, 145, 170, 200, 235, 270, 310, 355, 405, 460, 520, 585, ...
     655, 730, 810, 895, 985, 1080, 1180, 1290, 1410, 1540, 1680, ...
     1830, 1990, 2160, 2340, 2530, 2730]; % Frecuencia (Hz)

Z = [152.3, 149.1, 146.8, 144.9, 142.0, 139.5, 137.9, 136.1, 134.8, ...
     133.6, 132.7, 131.9, 131.4, 131.1, 130.9, 131.0, 131.3, 131.9, ...
     132.7, 133.8, 135.2, 136.9, 138.9, 141.1, 143.5, 146.1, 149.0, ...
     152.2, 155.6, 159.2]; % Magnitud de Impedancia (Ohm)

n_puntos = length(f); % 30 puntos
f_interp = linspace(min(f), max(f), 1000); % Grilla fina para graficar

% =========================================================================
% B1.1: Interpolación polinómica global de grado 29 (Vandermonde)
% =========================================================================
V = zeros(n_puntos, n_puntos);
for i = 1:n_puntos
    V(:, i) = (f.^(n_puntos - i))';
end

warning('off', 'MATLAB:polyfit:RepeatedPointsOrInfiniteValues');
warning('off', 'MATLAB:nearlySingularMatrix');
coefs_vandermonde = V \ Z';
Z_vander_eval = polyval(coefs_vandermonde, f_interp);

% =========================================================================
% B1.2: Comparación de grados (5, 10, 15) para evidenciar Runge
% =========================================================================
p5  = polyfit(f, Z, 5);
p10 = polyfit(f, Z, 10);
p15 = polyfit(f, Z, 15);

Z_p5_eval  = polyval(p5, f_interp);
Z_p10_eval = polyval(p10, f_interp);
Z_p15_eval = polyval(p15, f_interp);

% =========================================================================
% B2.1 & B2.2: Construcción y Evaluación del Spline Cúbico Natural
% =========================================================================
% Evaluamos usando la función local que implementa las condiciones de borde naturales S''(x_1) = S''(x_n) = 0
Z_spline_eval = natural_cubic_spline(f, Z, f_interp);

% =========================================================================
% GENERACIÓN DE GRÁFICOS COMPARATIVOS (B1 y B2)
% =========================================================================
figure('Name', 'Estudio de Interpolación de Impedancia', 'Color', 'w', 'Position', [100, 100, 1000, 700]);

% Subplot 1: Evidencia del Fenómeno de Runge (B1)
subplot(2, 1, 1);
plot(f, Z, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Datos Experimentales');
hold on;
plot(f_interp, Z_vander_eval, 'r-', 'LineWidth', 1.8, 'DisplayName', 'Polinomio Grado 29 (Vandermonde)');
plot(f_interp, Z_p5_eval, 'g--', 'LineWidth', 1.8, 'DisplayName', 'Polinomio Grado 5 (Seleccionado)');
plot(f_interp, Z_p10_eval, 'b-.', 'LineWidth', 1.2, 'DisplayName', 'Polinomio Grado 10');
plot(f_interp, Z_p15_eval, 'm:', 'LineWidth', 1.5, 'DisplayName', 'Polinomio Grado 15');
title('B1 - Evidencia del Fenómeno de Runge (Grado 29 frente a Grados Menores)', 'FontSize', 11);
xlabel('Frecuencia f (Hz)');
ylabel('Impedancia |Z| (\Omega)');
ylim([100, 180]); % Ajuste de límites para apreciar el comportamiento de Runge
grid on;
legend('Location', 'northeast');
hold off;

% Subplot 2: Comparación del Polinomio Seleccionado vs Spline Cúbico Natural (B2)
subplot(2, 1, 2);
plot(f, Z, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Datos Experimentales');
hold on;
plot(f_interp, Z_p5_eval, 'g--', 'LineWidth', 2.0, 'DisplayName', 'Polinomio Grado 5');
plot(f_interp, Z_spline_eval, 'c-', 'LineWidth', 1.8, 'DisplayName', 'Spline Cúbico Natural');
title('B2 - Comparación: Polinomio Seleccionado (Grado 5) vs Spline Cúbico Natural', 'FontSize', 11);
xlabel('Frecuencia f (Hz)');
ylabel('Impedancia |Z| (\Omega)');
ylim([128, 162]);
grid on;
legend('Location', 'northeast');
hold off;

% =========================================================================
% B2.3: Cálculo de |Z| en f = 1000 Hz empleando ambos métodos
% =========================================================================
f_target = 1000;

% 1. Evaluación con Polinomio Grado 5
Z_poly_1000 = polyval(p5, f_target);

% 2. Evaluación con Spline Cúbico Natural
Z_spline_1000 = natural_cubic_spline(f, Z, f_target);

% Impresión de resultados por consola
fprintf('=============================================================\n');
fprintf('RESULTADOS COMPARATIVOS EN f = %d Hz\n', f_target);
fprintf('=============================================================\n');
fprintf('1. Polinomio Seleccionado (Grado 5):    |Z| = %.4f Ohm\n', Z_poly_1000);
fprintf('2. Spline Cúbico Natural:                |Z| = %.4f Ohm\n', Z_spline_1000);
fprintf('Diferencia absoluta entre métodos:       %.4f Ohm\n', abs(Z_poly_1000 - Z_spline_1000));
fprintf('=============================================================\n\n');

% =========================================================================
% PROCEDIMIENTO DE VALIDACIÓN LOO (De la sección B1 - Se mantiene para reporte)
% =========================================================================
rng(42); 
indices_azar = randperm(n_puntos, 5); 
errores_relativos = zeros(1, 5);

fprintf('Validación Leave-One-Out (LOO) para el Polinomio Grado 5:\n');
for idx = 1:5
    i_omitido = indices_azar(idx);
    f_train = f; f_train(i_omitido) = [];
    Z_train = Z; Z_train(i_omitido) = [];
    
    p_train = polyfit(f_train, Z_train, 5);
    Z_val_pred = polyval(p_train, f(i_omitido));
    errores_relativos(idx) = abs(Z(i_omitido) - Z_val_pred) / Z(i_omitido);
end
fprintf('Error Relativo Promedio Estimado (LOO): %.4f%%\n', mean(errores_relativos) * 100);
fprintf('=============================================================\n');


% =========================================================================
% FUNCIONES LOCALES
% =========================================================================

function y_eval = natural_cubic_spline(x, y, x_eval)
% Genera y evalúa un Spline Cúbico Natural exacto S''(x_1) = S''(x_n) = 0
% x, y: Nodos de interpolación
% x_eval: Puntos donde se desea evaluar el spline
    
    n = length(x);
    h = diff(x); % Intervalos entre nodos h_i = x_{i+1} - x_i
    
    % Construcción del sistema tridiagonal para las segundas derivadas (g)
    A = zeros(n, n);
    B = zeros(n, 1);
    
    % Condiciones de frontera natural: S''(x_1) = 0, S''(x_n) = 0
    A(1, 1) = 1;
    A(n, n) = 1;
    
    % Ecuaciones internas para la continuidad de la primera derivada
    for i = 2:n-1
        A(i, i-1) = h(i-1)/6;
        A(i, i)   = (h(i-1) + h(i))/3;
        A(i, i+1) = h(i)/6;
        B(i)      = (y(i+1) - y(i))/h(i) - (y(i) - y(i-1))/h(i-1);
    end
    
    % Resolución del sistema lineal para obtener los coeficientes g (segundas derivadas)
    g = A \ B;
    
    % Evaluación del Spline para cada punto solicitado
    m = length(x_eval);
    y_eval = zeros(size(x_eval));
    
    for k = 1:m
        cur_x = x_eval(k);
        
        % Localizar el intervalo [x_i, x_{i+1}] que contiene a cur_x
        if cur_x <= x(1)
            i = 1;
        elseif cur_x >= x(end)
            i = n-1;
        else
            i = find(x <= cur_x, 1, 'last');
            if i == n, i = n-1; end
        end
        
        dx_p = cur_x - x(i);      % (x - x_i)
        dx_m = x(i+1) - cur_x;    % (x_{i+1} - x)
        hi = h(i);
        
        % Ecuación explícita del spline cúbico en el intervalo i
        val = (g(i+1)/(6*hi)) * (dx_p^3) + (g(i)/(6*hi)) * (dx_m^3) + ...
              (y(i+1)/hi - hi*g(i+1)/6) * dx_p + (y(i)/hi - hi*g(i)/6) * dx_m;
        y_eval(k) = val;
    end
end

function Z_eval = lagrange_interpolation(x, y, x_eval)
% Evaluación polinómica tradicional usando Lagrange
    n = length(x);
    m = length(x_eval);
    Z_eval = zeros(1, m);
    for k = 1:m
        val = 0;
        for i = 1:n
            L_i = 1;
            for j = 1:n
                if j ~= i
                    L_i = L_i * (x_eval(k) - x(j)) / (x(i) - x(j));
                end
            end
            val = val + y(i) * L_i;
        end
        Z_eval(k) = val;
    end
end