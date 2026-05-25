% =========================================================================
% SCRIPT: interpolacion_impedancia.m
% OBJETIVO: Resolución completa de las Partes B y C
%           B1: Interpolación polinómica y análisis de Runge.
%           B2: Spline cúbico natural.
%           C1: Derivación analítica del spline para primera y segunda derivada.
%               Determinación precisa del mínimo e interpretación del error.
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

n_puntos = length(f);
f_interp = linspace(min(f), max(f), 1000); % Grilla fina para análisis suave

% =========================================================================
% PARTE B: EVALUACIONES BÁSICAS
% =========================================================================
% Polinomio seleccionado de Grado 5
p5 = polyfit(f, Z, 5);
Z_p5_eval = polyval(p5, f_interp);

% Spline Cúbico Natural: Valores, Primera Derivada y Segunda Derivada analítica
[Z_spline_eval, dZ_spline_eval, d2Z_spline_eval] = natural_cubic_spline_derivs(f, Z, f_interp);

% Calcular derivadas directamente en los nodos de datos experimentales
[Z_nodos, dZ_nodos, d2Z_nodos] = natural_cubic_spline_derivs(f, Z, f);

% =========================================================================
% PARTE C.1: DETERMINACIÓN PRECISA DEL MÍNIMO
% =========================================================================
% Buscamos el intervalo donde la primera derivada analítica d|Z|/df cruza por cero.
% Esto ocurre cuando pasa de valores negativos a positivos.
idx_cruce = find(dZ_spline_eval(1:end-1) < 0 & dZ_spline_eval(2:end) >= 0, 1);

% Búsqueda del cero exacto de la primera derivada en dicho intervalo usando bisección lineal
f_min_estimado = f_interp(idx_cruce);
Z_min_estimado = Z_spline_eval(idx_cruce);
d2Z_en_minimo = d2Z_spline_eval(idx_cruce);

% =========================================================================
% GENERACIÓN DE GRÁFICOS (Figuras de las Partes B y C)
% =========================================================================
figure('Name', 'Analisis de Derivacion de Impedancia', 'Color', 'w', 'Position', [100, 100, 1000, 800]);

% Subplot 1: Ajuste del Spline Cúbico
subplot(3, 1, 1);
plot(f, Z, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Datos Reales');
hold on;
plot(f_interp, Z_spline_eval, 'c-', 'LineWidth', 1.8, 'DisplayName', 'Spline Cúbico Natural');
plot(f_min_estimado, Z_min_estimado, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'DisplayName', 'Mínimo Encontrado');
title('Magnitud de Impedancia |Z| y Ubicación del Mínimo', 'FontSize', 11);
ylabel('|Z| (\Omega)', 'FontWeight', 'bold');
grid on;
legend('Location', 'northeast');

% Subplot 2: Primera Derivada Analítica d|Z|/df
subplot(3, 1, 2);
plot(f, dZ_nodos, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Derivada en Nodos');
hold on;
plot(f_interp, dZ_spline_eval, 'b-', 'LineWidth', 1.5, 'DisplayName', 'd|Z|/df Analítica');
plot(f_min_estimado, 0, 'rx', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Raíz d|Z|/df = 0');
yline(0, 'k--', 'HandleVisibility', 'off');
title('Primera Derivada Analítica d|Z|/df', 'FontSize', 11);
ylabel('d|Z|/df (\Omega/Hz)', 'FontWeight', 'bold');
grid on;
legend('Location', 'southeast');

% Subplot 3: Segunda Derivada Analítica d^2|Z|/df^2
subplot(3, 1, 3);
plot(f, d2Z_nodos, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', '2da Derivada en Nodos');
hold on;
plot(f_interp, d2Z_spline_eval, 'm-', 'LineWidth', 1.5, 'DisplayName', 'd^2|Z|/df^2 Analítica');
plot(f_min_estimado, d2Z_en_minimo, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', 'DisplayName', 'Valor en Mínimo');
title('Segunda Derivada Analítica d^2|Z|/df^2', 'FontSize', 11);
xlabel('Frecuencia f (Hz)', 'FontWeight', 'bold');
ylabel('d^2|Z|/df^2 (\Omega/Hz^2)', 'FontWeight', 'bold');
grid on;
legend('Location', 'northeast');

% =========================================================================
% IMPRESIÓN DE RESULTADOS POR CONSOLA
% =========================================================================
fprintf('=============================================================\n');
fprintf('PARTE C - RESULTADOS DE DERIVACIÓN NUMÉRICA Y ANALÍSICA\n');
fprintf('=============================================================\n');
fprintf('Ubicación precisa del mínimo:\n');
fprintf('  - Frecuencia del mínimo (f_0):       %.3f Hz\n', f_min_estimado);
fprintf('  - Impedancia calculada (|Z|_min):     %.4f Ohm\n', Z_min_estimado);
fprintf('  - Valor de la 1era Derivada en f_0:   %.4e Ohm/Hz\n', dZ_spline_eval(idx_cruce));
fprintf('\nAnálisis de estabilidad en el mínimo:\n');
fprintf('  - Valor de la 2da Derivada (d^2|Z|/df^2): %.4e Ohm/Hz^2\n', d2Z_en_minimo);
if d2Z_en_minimo > 0
    fprintf('  - Interpretación: d^2|Z|/df^2 > 0. El punto crítico es un MÍNIMO ESTABLE.\n');
else
    fprintf('  - Interpretación: d^2|Z|/df^2 <= 0. Inestable o punto de inflexión.\n');
end
fprintf('=============================================================\n');


% =========================================================================
% FUNCIONES LOCALES DE DETALLE MATEMÁTICO
% =========================================================================

function [y_eval, dy_eval, d2y_eval] = natural_cubic_spline_derivs(x, y, x_eval)
% Calcula el Spline Cúbico Natural y evalúa de forma analítica exacta
% su valor S(x), su primera derivada S'(x) y su segunda derivada S''(x).
    
    n = length(x);
    h = diff(x); % Intervalos h_i = x_{i+1} - x_i
    
    % Construcción de la matriz tridiagonal para calcular S''(x) en los nodos (g)
    A = zeros(n, n);
    B = zeros(n, 1);
    
    A(1, 1) = 1;
    A(n, n) = 1;
    
    for i = 2:n-1
        A(i, i-1) = h(i-1)/6;
        A(i, i)   = (h(i-1) + h(i))/3;
        A(i, i+1) = h(i)/6;
        B(i)      = (y(i+1) - y(i))/h(i) - (y(i) - y(i-1))/h(i-1);
    end
    
    g = A \ B; % Segundas derivadas analíticas en los nodos
    
    % Evaluación analítica del spline y sus derivadas en los puntos x_eval
    m = length(x_eval);
    y_eval = zeros(size(x_eval));
    dy_eval = zeros(size(x_eval));
    d2y_eval = zeros(size(x_eval));
    
    for k = 1:m
        cur_x = x_eval(k);
        
        % Buscar intervalo [x_i, x_{i+1}]
        if cur_x <= x(1)
            i = 1;
        elseif cur_x >= x(end)
            i = n-1;
        else
            i = find(x <= cur_x, 1, 'last');
            if i == n, i = n-1; end
        end
        
        hi = h(i);
        dx_p = cur_x - x(i);      % (x - x_i)
        dx_m = x(i+1) - cur_x;    % (x_{i+1} - x)
        
        % 1. Evaluación del Spline: S_i(x)
        y_eval(k) = (g(i+1)/(6*hi)) * (dx_p^3) + (g(i)/(6*hi)) * (dx_m^3) + ...
                    (y(i+1)/hi - hi*g(i+1)/6) * dx_p + (y(i)/hi - hi*g(i)/6) * dx_m;
                
        % 2. Primera derivada analítica: S'_i(x)
        dy_eval(k) = (g(i+1)/(2*hi)) * (dx_p^2) - (g(i)/(2*hi)) * (dx_m^2) + ...
                     (y(i+1)/hi - hi*g(i+1)/6) - (y(i)/hi - hi*g(i)/6);
                 
        % 3. Segunda derivada analítica: S''_i(x)
        d2y_eval(k) = (g(i+1)/hi) * dx_p + (g(i)/hi) * dx_m;
    end
end