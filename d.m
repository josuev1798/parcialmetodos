% =========================================================================
% SCRIPT: interpolacion_impedancia.m (SOLO PARTE D)
% OBJETIVO: Búsqueda de raíces de |Z|(f) - Z_th = 0 usando:
%           1. Método de Bisección.
%           2. Método de Newton-Raphson (con derivada analítica del spline).
%           3. Cálculo de la sensibilidad df/d|Z| en la raíz de ~2200 Hz.
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

% Grilla fina para evaluar el spline continuamente
f_interp = linspace(min(f), max(f), 1000); 
[Z_spline, ~, ~] = natural_cubic_spline_derivs(f, Z, f_interp);

% =========================================================================
% CONFIGURACIÓN DEL UMBRAL Y PARÁMETROS
% =========================================================================
Z_th = 150.0; % Umbral limitante en Ohm
tol = 1e-6;   % Tolerancia para asegurar al menos 4 cifras significativas
max_iter = 100;

% Identificación de los intervalos donde la curva cruza el umbral de 150 Ohm
Z_shifted = Z_spline - Z_th;
idx_cruces = find(Z_shifted(1:end-1) .* Z_shifted(2:end) < 0);

% Definición de intervalos de búsqueda iniciales basados en los cruces detectados
r1_intervalo = [f_interp(idx_cruces(1)), f_interp(idx_cruces(1)+1)];
r2_intervalo = [f_interp(idx_cruces(2)), f_interp(idx_cruces(2)+1)];

% =========================================================================
% 1. MÉTODO DE BISECCIÓN
% =========================================================================
[root1_bis, iter1_bis] = bisection_method(f, Z, Z_th, r1_intervalo(1), r1_intervalo(2), tol, max_iter);
[root2_bis, iter2_bis] = bisection_method(f, Z, Z_th, r2_intervalo(1), r2_intervalo(2), tol, max_iter);

% =========================================================================
% 2. MÉTODO DE NEWTON-RAPHSON (Con derivada analítica del Spline)
% =========================================================================
% Aproximaciones iniciales basadas en los bordes de los intervalos detectados
x0_1 = r1_intervalo(1);
x0_2 = r2_intervalo(2);

[root1_newt, iter1_newt] = newton_method(f, Z, Z_th, x0_1, tol, max_iter);
[root2_newt, iter2_newt] = newton_method(f, Z, Z_th, x0_2, tol, max_iter);

% =========================================================================
% 3. ANÁLISIS DE SENSIBILIDAD df/d|Z| (Para la raíz cercana a ~2200 Hz)
% =========================================================================
[~, dZ_r2, ~] = natural_cubic_spline_derivs(f, Z, root2_newt);
sensibilidad_r2 = 1 / dZ_r2; % df/d|Z| en Hz/Ohm

% =========================================================================
% IMPRESIÓN DE RESULTADOS
% =========================================================================
fprintf('=============================================================\n');
fprintf('PARTE D - RESULTADOS DE BÚSQUEDA DE RAÍCES (UMBRAL = %.1f Ohm)\n', Z_th);
fprintf('=============================================================\n');
fprintf('Raíz 1 (Frecuencia límite baja):\n');
fprintf('  - Método Bisección:     %.6f Hz (en %d iteraciones)\n', root1_bis, iter1_bis);
fprintf('  - Método Newton-Raphson: %.6f Hz (en %d iteraciones)\n', root1_newt, iter1_newt);
fprintf('\nRaíz 2 (Frecuencia límite alta - cercana a 2200 Hz):\n');
fprintf('  - Método Bisección:     %.6f Hz (en %d iteraciones)\n', root2_bis, iter2_bis);
fprintf('  - Método Newton-Raphson: %.6f Hz (en %d iteraciones)\n', root2_newt, iter2_newt);

fprintf('\nBANDA DE OPERACIÓN SEGURA (|Z| <= %.1f Ohm):\n', Z_th);
fprintf('  Frecuencias seguras:  [ %.4f Hz  ---  %.4f Hz ]\n', root1_newt, root2_newt);

fprintf('\nCÁLCULO DE SENSIBILIDAD EN LA RAÍZ ALTA (f = %.4f Hz):\n', root2_newt);
fprintf('  - Derivada analítica d|Z|/df en la raíz:  %.6f Ohm/Hz\n', dZ_r2);
fprintf('  - Sensibilidad analítica df/d|Z|:          %.6f Hz/Ohm\n', sensibilidad_r2);
fprintf('=============================================================\n');

% =========================================================================
% GENERACIÓN DE GRÁFICA
% =========================================================================
figure('Name', 'Parte D - Banda de Operacion Segura', 'Color', 'w', 'Position', [150, 150, 900, 500]);
plot(f_interp, Z_spline, 'c-', 'LineWidth', 2, 'DisplayName', 'Spline Cúbico Natural |Z|(f)');
hold on;
plot(f, Z, 'ko', 'MarkerFaceColor', 'k', 'DisplayName', 'Datos Experimentales');
yline(Z_th, 'r--', 'LineWidth', 1.5, 'DisplayName', sprintf('Umbral Z_{th} = %.1f \\Omega', Z_th));

% Resaltar las raíces en la gráfica
plot(root1_newt, Z_th, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g', ...
     'DisplayName', sprintf('Límite Inferior: %.2f Hz', root1_newt));
plot(root2_newt, Z_th, 'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b', ...
     'DisplayName', sprintf('Límite Superior: %.2f Hz', root2_newt));

title('Identificación de la Banda de Operación Segura (|Z| < 150 \Omega)', 'FontSize', 12);
xlabel('Frecuencia f (Hz)', 'FontWeight', 'bold');
ylabel('Impedancia |Z| (\Omega)', 'FontWeight', 'bold');
grid on;
legend('Location', 'northeast');
hold off;

% =========================================================================
% FUNCIONES LOCALES (ALGORITMOS)
% =========================================================================

function [root, iter] = bisection_method(x_data, y_data, target, a, b, tol, max_iter)
% Encuentra la raíz de S(x) - target = 0 en el intervalo [a, b] usando Bisección
    iter = 0;
    fa = evaluate_spline_offset(x_data, y_data, target, a);
    fb = evaluate_spline_offset(x_data, y_data, target, b);
    
    if fa * fb > 0
        error('El intervalo [%f, %f] no contiene un cambio de signo.', a, b);
    end
    
    while (b - a)/2 > tol && iter < max_iter
        iter = iter + 1;
        c = (a + b)/2;
        fc = evaluate_spline_offset(x_data, y_data, target, c);
        
        if abs(fc) < 1e-12
            root = c;
            return;
        elseif fa * fc < 0
            b = c;
        else
            a = c;
            fa = fc;
        end
    end
    root = (a + b)/2;
end

function [root, iter] = newton_method(x_data, y_data, target, x0, tol, max_iter)
% Encuentra la raíz de S(x) - target = 0 usando el método de Newton-Raphson
    iter = 0;
    root = x0;
    while iter < max_iter
        iter = iter + 1;
        [val, dval, ~] = natural_cubic_spline_derivs(x_data, y_data, root);
        f_val = val - target;
        
        if abs(dval) < 1e-12
            warning('Derivada cercana a cero detectada en Newton-Raphson.');
            break;
        end
        
        next_root = root - f_val / dval;
        
        if abs(next_root - root) < tol
            root = next_root;
            return;
        end
        root = next_root;
    end
end

function val = evaluate_spline_offset(x_data, y_data, target, x_eval)
% Helper para evaluar la diferencia contra el umbral: S(x) - Z_th
    [val, ~, ~] = natural_cubic_spline_derivs(x_data, y_data, x_eval);
    val = val - target;
end

function [y_eval, dy_eval, d2y_eval] = natural_cubic_spline_derivs(x, y, x_eval)
% Calcula el valor, la primera y la segunda derivada analítica de un spline natural.
    n = length(x);
    h = diff(x);
    
    % Sistema lineal para segundas derivadas (g)
    A = zeros(n, n);
    B = zeros(n, 1);
    A(1, 1) = 1; A(n, n) = 1;
    for i = 2:n-1
        A(i, i-1) = h(i-1)/6;
        A(i, i)   = (h(i-1) + h(i))/3;
        A(i, i+1) = h(i)/6;
        B(i)      = (y(i+1) - y(i))/h(i) - (y(i) - y(i-1))/h(i-1);
    end
    g = A \ B;
    
    % Evaluación en los puntos solicitados (x_eval)
    m = length(x_eval);
    y_eval = zeros(size(x_eval));
    dy_eval = zeros(size(x_eval));
    d2y_eval = zeros(size(x_eval));
    
    for k = 1:m
        cur_x = x_eval(k);
        if cur_x <= x(1)
            i = 1;
        elseif cur_x >= x(end)
            i = n-1;
        else
            i = find(x <= cur_x, 1, 'last');
            if i == n, i = n-1; end
        end
        hi = h(i);
        dx_p = cur_x - x(i);
        dx_m = x(i+1) - cur_x;
        
        % S_i(x)
        y_eval(k) = (g(i+1)/(6*hi)) * (dx_p^3) + (g(i)/(6*hi)) * (dx_m^3) + ...
                    (y(i+1)/hi - hi*g(i+1)/6) * dx_p + (y(i)/hi - hi*g(i)/6) * dx_m;
        % S'_i(x)
        dy_eval(k) = (g(i+1)/(2*hi)) * (dx_p^2) - (g(i)/(2*hi)) * (dx_m^2) + ...
                     (y(i+1)/hi - hi*g(i+1)/6) - (y(i)/hi - hi*g(i)/6);
        % S''_i(x)
        d2y_eval(k) = (g(i+1)/hi) * dx_p + (g(i)/hi) * dx_m;
    end
end