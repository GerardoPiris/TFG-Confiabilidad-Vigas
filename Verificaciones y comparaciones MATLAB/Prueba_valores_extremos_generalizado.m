% Par�metros de la distribuci�n
mu = 0;     % Localizaci�n
sigma = 1;  % Escala
xi = 0;     % Forma (0 indica distribuci�n de Gumbel)

% Generar n valores aleatorios de la distribuci�n GEV para m�ximos
n = 100000; % N�mero de valores
X_max = gevrnd(xi, sigma, mu, n, 1);

% Graficar histograma de los valores generados
histogram(X_max, 100, 'Normalization', 'pdf'); hold on;

% Funci�n de densidad te�rica de la GEV
x = linspace(min(X_max), max(X_max), 1000);
pdf_max = gevpdf(x, xi, sigma, mu);

% Graficar la densidad te�rica
plot(x, pdf_max, 'r', 'LineWidth', 2);
hold off;

legend('Datos generados', 'FDP te�rica');
xlabel('x'); ylabel('Densidad de probabilidad');
title('Distribuci�n Gumbel (GEV, m�ximos)');

% Par�metros de la distribuci�n
xi = 0; % Par�metro de forma
mu = 0; % Par�metro de ubicaci�n
sigma = 1; % Par�metro de escala
n_samples = 2000000; % N�mero de muestras

% Generaci�n de n�meros aleatorios con gevrnd
data_gevrnd = gevrnd(xi, sigma, mu, [n_samples, 1]);

% Generaci�n de n�meros aleatorios con makedist y random
gev_dist = makedist('GeneralizedExtremeValue', 'k', xi, 'sigma', sigma, 'mu', mu);
data_makedist = random(gev_dist, [n_samples, 1]);

% C�lculo de par�metros estad�sticos
stats_gevrnd = [mean(data_gevrnd), var(data_gevrnd), skewness(data_gevrnd), kurtosis(data_gevrnd)];
stats_makedist = [mean(data_makedist), var(data_makedist), skewness(data_makedist), kurtosis(data_makedist)];

% Comparaci�n gr�fica
figure;
hold on;
histogram(data_gevrnd, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'b', 'LineWidth', 1.5, 'DisplayName', 'gevrnd');
histogram(data_makedist, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 1.5, 'DisplayName', 'makedist');
legend('Location', 'best');
xlabel('Valores');
ylabel('Densidad de Probabilidad');
title('Comparaci�n de distribuciones GEV generadas por gevrnd y makedist');
grid on;

% Mostrar los par�metros estad�sticos
fprintf('Par�metros Estad�sticos:\n');
fprintf('M�todo\t\t Media\t\t Varianza\t Asimetr�a\t Curtosis\n');
fprintf('gevrnd\t\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_gevrnd);
fprintf('makedist\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_makedist);
