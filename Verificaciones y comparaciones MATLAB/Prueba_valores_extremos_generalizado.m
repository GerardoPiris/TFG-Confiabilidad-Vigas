% Parámetros de la distribución
mu = 0;     % Localización
sigma = 1;  % Escala
xi = 0;     % Forma (0 indica distribución de Gumbel)

% Generar n valores aleatorios de la distribución GEV para máximos
n = 100000; % Número de valores
X_max = gevrnd(xi, sigma, mu, n, 1);

% Graficar histograma de los valores generados
histogram(X_max, 100, 'Normalization', 'pdf'); hold on;

% Función de densidad teórica de la GEV
x = linspace(min(X_max), max(X_max), 1000);
pdf_max = gevpdf(x, xi, sigma, mu);

% Graficar la densidad teórica
plot(x, pdf_max, 'r', 'LineWidth', 2);
hold off;

legend('Datos generados', 'FDP teórica');
xlabel('x'); ylabel('Densidad de probabilidad');
title('Distribución Gumbel (GEV, máximos)');

% Parámetros de la distribución
xi = 0; % Parámetro de forma
mu = 0; % Parámetro de ubicación
sigma = 1; % Parámetro de escala
n_samples = 2000000; % Número de muestras

% Generación de números aleatorios con gevrnd
data_gevrnd = gevrnd(xi, sigma, mu, [n_samples, 1]);

% Generación de números aleatorios con makedist y random
gev_dist = makedist('GeneralizedExtremeValue', 'k', xi, 'sigma', sigma, 'mu', mu);
data_makedist = random(gev_dist, [n_samples, 1]);

% Cálculo de parámetros estadísticos
stats_gevrnd = [mean(data_gevrnd), var(data_gevrnd), skewness(data_gevrnd), kurtosis(data_gevrnd)];
stats_makedist = [mean(data_makedist), var(data_makedist), skewness(data_makedist), kurtosis(data_makedist)];

% Comparación gráfica
figure;
hold on;
histogram(data_gevrnd, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'b', 'LineWidth', 1.5, 'DisplayName', 'gevrnd');
histogram(data_makedist, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 1.5, 'DisplayName', 'makedist');
legend('Location', 'best');
xlabel('Valores');
ylabel('Densidad de Probabilidad');
title('Comparación de distribuciones GEV generadas por gevrnd y makedist');
grid on;

% Mostrar los parámetros estadísticos
fprintf('Parámetros Estadísticos:\n');
fprintf('Método\t\t Media\t\t Varianza\t Asimetría\t Curtosis\n');
fprintf('gevrnd\t\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_gevrnd);
fprintf('makedist\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_makedist);
