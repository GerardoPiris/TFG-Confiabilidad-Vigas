clear
close all
clc
% Leer archivos xls
filePath = 'Datos de distribuciones_Caso1.xlsx';%aclarar si es distribuciones o distribuciones2 dependiendo del caso
bias_cov = xlsread(filePath, 'bias y CoV para matlab', 'A2:I3'); % Factor bias y coeficientes de variación

% Leer datos de diseño de las vigas (desde la fila 3, columnas c a I)
valores_diseno = xlsread(filePath, 'Datos vigas para matlab', 'C3:I102'); 

% Definir número de simulaciones
N = 2e6; % input('Introduce el número de simulaciones por viga: ');

% Medir el tiempo total de ejecución
tic;

% Inicializar matrices para almacenar tiempos de cada viga
num_vigas = size(valores_diseno, 1); % Detecta automáticamente el número de vigas
tiempos_viga = zeros(num_vigas, 1);

% Extraer datos de bias y coef. variación de cada variable
bias_resistencia_modelo = bias_cov(1, 1);   cov_resistencia_modelo = bias_cov(2, 1);
bias_solicitante_modelo = bias_cov(1, 2);   cov_solicitante_modelo = bias_cov(2, 2);
bias_carga_muerta = bias_cov(1, 3);         cov_carga_muerta = bias_cov(2, 3);
bias_carga_viva = bias_cov(1, 4);           cov_carga_viva = bias_cov(2, 4);
bias_fc = bias_cov(1, 5);                   cov_fc = bias_cov(2, 5);
bias_fy = bias_cov(1, 6);                   cov_fy = bias_cov(2, 6);
bias_b = bias_cov(1, 7);                    cov_b = bias_cov(2, 7);
bias_d = bias_cov(1, 8);                    cov_d = bias_cov(2, 8);
bias_As = bias_cov(1, 9);                   cov_As = bias_cov(2, 9);

% Establecer la semilla basada en el tiempo actual
rng('shuffle');

% Loop a través de cada viga en los valores de diseño
resultados_fallas = zeros(num_vigas, 1);
beta_vigas = zeros(num_vigas, 1);

% Definir las vigas de interés
vigas_interes = [1, 25, 26, 50, 51, 75, 76, 100]; % Cambia según el caso
hist_data = struct();

for i = 1:num_vigas
    % Valores de diseño para la viga i-ésima
    diseno = valores_diseno(i, :);
    M_muerto_diseno = diseno(1); 
    M_vivo_diseno = diseno(2); 
    fc_diseno = diseno(3);
    fy_diseno = diseno(4);
    b_diseno = diseno(5);
    d_diseno = diseno(6);
    As_diseno = diseno(7);
          
    % Generar muestras aleatorias para cada variable
    mu_R=bias_resistencia_modelo;
    zeta_R=log(1+(cov_resistencia_modelo)^2); 
    lambda_R=log(mu_R)-1/2*zeta_R;
    resistencia_modelo = lognrnd(lambda_R, sqrt(zeta_R), N, 1);
    mu_S=bias_solicitante_modelo;
    zeta_S=log(1+(cov_solicitante_modelo)^2);
    lambda_S=log(mu_S)-1/2*zeta_R;
    solicitante_modelo = lognrnd(lambda_S, sqrt(zeta_S), N, 1);
    xi=0; % especifica que sea una distribución tipo I
    gamma = double(eulergamma); % Constante de Euler-Mascheroni
    beta_gumbel = (cov_carga_viva*bias_carga_viva*M_vivo_diseno) * sqrt(6) / pi; % Parámetro de escala
    alpha_gumbel = bias_carga_viva*M_vivo_diseno - gamma * beta_gumbel; % Parámetro de ubicación
    momento_flector_vivo = gevrnd(xi, beta_gumbel, alpha_gumbel, N, 1); % Gumbel para cargas vivas
    momento_flector_muerto = normrnd(bias_carga_muerta * M_muerto_diseno, cov_carga_muerta * bias_carga_muerta * M_muerto_diseno, N, 1); % Normal para cargas muertas
    fc_muestra = normrnd(bias_fc * fc_diseno, cov_fc * bias_fc * fc_diseno, N, 1);
    fy_muestra = normrnd(bias_fy * fy_diseno, cov_fy * bias_fy * fy_diseno, N, 1);
    b_muestra = normrnd(bias_b * b_diseno, cov_b * bias_b * b_diseno, N, 1);
    d_muestra = normrnd(bias_d * d_diseno, cov_d * bias_d * d_diseno, N, 1);
    As_muestra = normrnd(bias_As * As_diseno, cov_As * bias_As * diseno(7), N, 1);

    % Momento resistente (según fórmula del ACI)
    Mr = resistencia_modelo.* As_muestra .* fy_muestra .* d_muestra .* (1 - (As_muestra .* fy_muestra) ./ (2*0.85* fc_muestra .* b_muestra .* d_muestra));

    % Momento solicitante (suma de cargas vivas y muertas)
    Ms = (momento_flector_vivo + momento_flector_muerto) .* solicitante_modelo;
    
    % Almacenar valores de Mr y Ms para las vigas de interés
    if ismember(i, vigas_interes)
        hist_data(i).Mr = Mr;
        hist_data(i).Ms = Ms;
    end

    % Verificar fallas
    fallas = Mr < Ms;
    porcentaje_fallas = sum(fallas) / N;

    % Confiabilidad
    beta = -norminv(porcentaje_fallas);

    % Guardar resultados
    resultados_fallas(i) = porcentaje_fallas;
    beta_vigas(i) = beta;
end

% Inicializar límites globales para el eje X
limite_x_min = inf;
limite_x_max = -inf;

% Calcular límites globales de los datos para el eje X
for i = vigas_interes
    % Datos de momento resistente (Mr) y momento solicitante (Ms)
    datos_Mr = hist_data(i).Mr; 
    datos_Ms = hist_data(i).Ms;
    
    % Actualizar límites del eje X
    limite_x_min = min([limite_x_min, min(datos_Mr), min(datos_Ms)]);
    limite_x_max = max([limite_x_max, max(datos_Mr), max(datos_Ms)]);
end

% Fijar límites de los ejes
limites_eje_x = [limite_x_min, limite_x_max]; % Límites automáticos para el eje X
limites_eje_y = [0, 20000]; % Límite máximo fijo en 30000 para el eje Y

% Generar gráficos con los mismos límites
for i = vigas_interes
    figure;
    hold on;

    % Crear histogramas
    histogram(hist_data(i).Mr, 'Normalization', 'count','BinWidth', 6000, ...
              'FaceColor', [0 0 1], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    histogram(hist_data(i).Ms, 'Normalization', 'count','BinWidth', 6000, ...
              'FaceColor', [1 0 0], 'FaceAlpha', 0.5, 'EdgeColor', 'none');
    
    % Configurar límites uniformes para los ejes
    xlim(limites_eje_x);
    ylim(limites_eje_y); %ylim(limites_eje_y);

    % Títulos y etiquetas
    title(sprintf('Histogramas de momentos para Viga %d', i));
    xlabel('Momentos');
    ylabel('Frecuencia');
    legend({'Mr', 'Ms'}, 'Location', 'best');
    grid on;
    hold off;
end

% Medir el tiempo total de simulación 
tiempo_total = toc;

% Mostrar resultados
disp('Porcentaje de fallas por viga:');
disp(resultados_fallas * 100); % En porcentaje

disp('Confiabilidad (beta) por viga:');
disp(beta_vigas);

disp('Tiempo total de simulación (en segundos):');
disp(tiempo_total);

% Preguntar si se desea guardar los resultados después de mostrarlos
guardar = input('¿Desea guardar los resultados? (sí=1, no=0): ');

if guardar == 1
    % Solicitar número del archivo
    numero = input('Ingrese el número del archivo de resultados: ', 's');
    nombre_archivo = ['Simulaciones de Monte Carlo número ', numero, '.xlsx'];
    
    % Crear una nueva tabla con los resultados
    headers = {'M_muerto', 'M_vivo', 'fc', 'fy', 'b', 'd', 'As', 'porcentaje de falla', 'confiabilidad'};
    datos_resultados = [valores_diseno, resultados_fallas * 100, beta_vigas]; % Agregar columnas adicionales
    
    % Escribir en el archivo Excel
    xlswrite(nombre_archivo, headers, 'resultados', 'A1');
    xlswrite(nombre_archivo, datos_resultados, 'resultados', 'A2');
    disp(['Resultados guardados en el archivo: ', nombre_archivo]);
end