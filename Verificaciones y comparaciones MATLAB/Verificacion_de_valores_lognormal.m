clear mean std
% Especificación de los parámetros de la distribución (media y desviación estándar)
mean_value = 1; % Media deseada
std_value = 0.1; % Desviación estándar deseada
N = 2e6; % Número de simulaciones

% Cálculo de los parámetros de la distribución Gumbel
zeta_ln = log(1 + (std_value^2) / (mean_value^2));
lambda_ln = log(mean_value)-1/2*zeta_ln;

% Método 1: Generación con evrnd
lognormal_rnd = lognrnd(lambda_ln, sqrt(zeta_ln), N, 1);

% Método 2: Generación con makedist
lognormal_dist = makedist('Lognormal', 'mu', lambda_ln, 'sigma', sqrt(zeta_ln));
lognormal_makedist = random(lognormal_dist, N, 1);

% Comparación numérica
stats_lognrnd = [mean(lognormal_rnd), std(lognormal_rnd), ...
               skewness(lognormal_rnd), kurtosis(lognormal_rnd)];
stats_makedist = [mean(lognormal_makedist), std(lognormal_makedist), ...
                  skewness(lognormal_makedist), kurtosis(lognormal_makedist)];

% Mostrar comparación numérica
fprintf('Comparación numérica:\n');
fprintf('Método         Media    Desv. Est.   Asimetría   Curtosis\n');
fprintf('evrnd        %8.4f  %8.4f  %8.4f  %8.4f\n', stats_lognrnd);
fprintf('makedist     %8.4f  %8.4f  %8.4f  %8.4f\n', stats_makedist);

% Comparación visual
figure;
subplot(2, 1, 1);
histogram(lognormal_rnd, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'b');
hold on;
histogram(lognormal_makedist, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r');
legend('evrnd', 'makedist');
title('Histogramas de densidad');
xlabel('Valor');
ylabel('Densidad');
grid on;

subplot(2, 1, 2);
[f_evrnd, x_evrnd] = ksdensity(lognormal_rnd);
[f_makedist, x_makedist] = ksdensity(lognormal_makedist);
plot(x_evrnd, f_evrnd, 'b', 'LineWidth', 1.5);
hold on;
plot(x_makedist, f_makedist, 'r--', 'LineWidth', 1.5);
legend('evrnd', 'makedist');
title('Curvas de densidad estimada');
xlabel('Valor');
ylabel('Densidad');
grid on;
