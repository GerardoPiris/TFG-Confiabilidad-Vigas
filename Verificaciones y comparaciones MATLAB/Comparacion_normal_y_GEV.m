clc
clear
% Constantes para ajuste de la distribuci�n GEV
gamma = 0.5772; % Constante de Euler-Mascheroni
std_target = 1; % Desviaci�n est�ndar deseada
mean_target = 0; % Media deseada

% C�lculo de par�metros de la GEV (xi=0)
sigma_gev = std_target * sqrt(6) / pi; % Escala
mu_gev = mean_target - sigma_gev * gamma; % Ubicaci�n
xi = 0; % Forma (distribuci�n Gumbel)

% Generaci�n de muestras
n_samples = 1e6; % N�mero de muestras
data_normal = normrnd(mean_target, std_target, [n_samples, 1]); % Distribuci�n normal
data_gev = gevrnd(xi, sigma_gev, mu_gev, [n_samples, 1]); % Distribuci�n GEV

% C�lculo de par�metros estad�sticos
stats_normal = [mean(data_normal), std(data_normal), skewness(data_normal), kurtosis(data_normal)];
stats_gev = [mean(data_gev), std(data_gev), skewness(data_gev), kurtosis(data_gev)];

% Comparaci�n gr�fica
figure;
hold on;
histogram(data_normal, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'b', 'LineWidth', 1.5, 'DisplayName', 'Normal');
histogram(data_gev, 'Normalization', 'pdf', 'DisplayStyle', 'stairs', 'EdgeColor', 'r', 'LineWidth', 1.5, 'DisplayName', 'GEV');
legend('Location', 'best');
xlabel('Valores');
ylabel('Densidad de Probabilidad');
title('Comparaci�n de distribuciones: Normal vs Generalized Extreme Value');
grid on;

% Mostrar los par�metros estad�sticos
fprintf('Par�metros Estad�sticos:\n');
fprintf('Distribuci�n\t Media\t\t Desv. Est.\t Asimetr�a\t Curtosis\n');
fprintf('Normal\t\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_normal);
fprintf('GEV\t\t %.4f\t %.4f\t %.4f\t %.4f\n', stats_gev);
