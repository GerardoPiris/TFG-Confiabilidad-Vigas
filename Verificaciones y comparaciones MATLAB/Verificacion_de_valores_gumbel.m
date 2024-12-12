clear mean std
% Especificaci�n de los par�metros de la distribuci�n (media y desviaci�n est�ndar)
mean_value = 1000; % Media deseada
std_value = 10; % Desviaci�n est�ndar deseada
N = 2e6; % N�mero de simulaciones

% C�lculo de los par�metros de la distribuci�n Gumbel
gamma = double(eulergamma); % Constante de Euler-Mascheroni
beta = std_value * sqrt(6) / pi; % Par�metro de escala
mu = mean_value + gamma * beta; % Par�metro de ubicaci�n

% M�todo 1: Generaci�n con evrnd
momento_flector_vivo_evrnd = evrnd(mu, beta, N, 1);

% M�todo 2: Generaci�n con makedist
gumbel_dist = makedist('ExtremeValue', 'mu', mu, 'sigma', beta);
momento_flector_vivo_makedist = random(gumbel_dist, N, 1);

% Comparaci�n num�rica
stats_evrnd = [mean(momento_flector_vivo_evrnd), std(momento_flector_vivo_evrnd), ...
               skewness(momento_flector_vivo_evrnd), kurtosis(momento_flector_vivo_evrnd)];
stats_makedist = [mean(momento_flector_vivo_makedist), std(momento_flector_vivo_makedist), ...
                  skewness(momento_flector_vivo_makedist), kurtosis(momento_flector_vivo_makedist)];

% Mostrar comparaci�n num�rica
fprintf('Comparaci�n num�rica:\n');
fprintf('M�todo         Media    Desv. Est.   Asimetr�a   Curtosis\n');
fprintf('evrnd        %8.4f  %8.4f  %8.4f  %8.4f\n', stats_evrnd);
fprintf('makedist     %8.4f  %8.4f  %8.4f  %8.4f\n', stats_makedist);

% Comparaci�n visual
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
