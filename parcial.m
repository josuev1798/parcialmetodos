% Script para graficar los datos de impedancia vs frecuencia
% y resaltar el mínimo local según la Parte A.

% 1. Definición de los datos extraídos de la tabla
f = [100, 120, 145, 170, 200, 235, 270, 310, 355, 405, 460, 520, 585, ...
    655, 730, 810, 895, 985, 1080, 1180, 1290, 1410, 1540, 1680, ...
    1830, 1990, 2160, 2340, 2530, 2730]; % Frecuencia en Hz

Z = [152.3, 149.1, 146.8, 144.9, 142.0, 139.5, 137.9, 136.1, 134.8, ...
    133.6, 132.7, 131.9, 131.4, 131.1, 130.9, 131.0, 131.3, 131.9, ...
    132.7, 133.8, 135.2, 136.9, 138.9, 141.1, 143.5, 146.1, 149.0, ...
    152.2, 155.6, 159.2]; % Magnitud de impedancia en ohms

% 2. Encontrar el mínimo local matemáticamente
[min_Z, idx_min] = min(Z);
min_f = f(idx_min);

% 3. Creación de la gráfica
figure('Name', 'Analisis Exploratorio de Impedancia', 'Color', 'w');
plot(f, Z, '-o', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', '#0072BD');
hold on;

% 4. Resaltar el punto mínimo en la gráfica
plot(min_f, min_Z, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
text(min_f, min_Z - 1.5, sprintf('Mínimo local: %.0f Hz, %.1f \\Omega', min_f, min_Z), ...
    'VerticalAlignment', 'top', 'HorizontalAlignment', 'center', ...
    'Color', 'r', 'FontSize', 11, 'FontWeight', 'bold');

% 5. Configuración de ejes y etiquetas
title('Magnitud de Impedancia |Z| en función de la frecuencia f', 'FontSize', 13);
xlabel('Frecuencia f (Hz)', 'FontSize', 11, 'FontWeight', 'bold');
ylabel('Magnitud de Impedancia |Z| (\Omega)', 'FontSize', 11, 'FontWeight', 'bold');
grid on;
hold off;