clear mean std
% Especificación de los parámetros de la distribución (media y desviación estándar)
mean_value = 1000; % Media deseada
std_value = 10; % Desviación estándar deseada
N = 2e6; % Número de simulaciones

% Cálculo de los parámetros de la distribución Gumbel
gamma = double(eulergamma); % Constante de Euler-Mascheroni
beta = std_value * sqrt(6) / pi; % Parámetro de escala
mu = mean_value + gamma * beta; % Parámetro de ubicación

% Método 1: Generación con evrnd
momento_flector_vivo_evrnd = evrnd(mu, beta, N, 1);

% Método 2: Generación con makedist
gumbel_dist = makedist('ExtremeValue', 'mu', mu, 'sigma', beta);
momento_flector_vivo_makedist = random(gumbel_dist, N, 1);

% Comparación numérica
stats_evrnd = [mean(momento_flector_vivo_evrnd), std(momento_flector_vivo_evrnd), ...
               skewness(momento_flector_vivo_evrnd), kurtosis(momento_flector_vivo_evrnd)];
stats_makedist = [mean(momento_flector_vivo_makedist), std(momento_flector_vivo_makedist), ...
                  skewness(momento_flector_vivo_makedist), kurtosis(momento_flector_vivo_makedist)];

% Mostrar comparación numérica
fprintf('Comparación numérica:\n');
fprintf('Método         Media    Desv. Est.   Asimetría   Curtosis\n');
fprintf('evrnd        %8.4f  %8.4f  %8.4f  %8.4f\n', stats_evrnd);
fprintf('makedist     %8.4f  %8.4f  %8.4f  %8.4f\n', stats_makedist);

% Comparación visual
figure;
subplot(2, 1, 1);
histogram(momento_flector_vivo_evrnd, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'b');
hold on;
histogram(momento_flector_vivo_makedist, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r');
legend('evrnd', 'makedist');
title('Histogramas de densidad');
xlabel('Valor');
ylabel('Densidad');
grid on;

subplot(2, 1, 2);
[f_evrnd, x_evrnd] = ksdensity(momento_flector_vivo_evrnd);
[f_makedist, x_makedist] = ksdensity(momento_flector_vivo_makedist);
plot(x_evrnd, f_evrnd, 'b', 'LineWidth', 1.5);
hold on;
plot(x_makedist, f_makedist, 'r--', 'LineWidth', 1.5);
legend('evrnd', 'makedist');
title('Curvas de densidad estimada');
xlabel('Valor');
ylabel('Densidad');
grid on;
