% Leer archivos xls
bias_cov = xlsread('Datos de distribuciones','bias y CoV para matlab','A2:I3'); % Factor bias y coeficientes de variación
valores_diseno = xlsread('Datos de distribuciones','Datos vigas para matlab','A3:G'); % Valores de diseño de las vigas

% Definir número de simulaciones
N = 2e6;%input('Introduce el número de simulaciones por viga: ');

% Medir el tiempo total de ejecución
tic; 

%Inicializar matrices para almacenar tiempos de cada viga
num_vigas = size(valores_diseno, 1);
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
    resistencia_modelo = lognrnd(log(bias_resistencia_modelo), cov_resistencia_modelo, N, 1);
    solicitante_modelo = lognrnd(log(bias_solicitante_modelo), cov_solicitante_modelo, N, 1);
    momento_flector_vivo = evrnd(bias_carga_viva*M_vivo_diseno, cov_carga_viva*bias_carga_viva*M_vivo_diseno, N, 1); % Gumbel para cargas vivas
    momento_flector_muerto = normrnd(bias_carga_muerta * M_muerto_diseno, cov_carga_muerta * bias_carga_muerta * M_muerto_diseno, N, 1); % Normal para cargas muertas
    fc_muestra = normrnd(bias_fc * fc_diseno, cov_fc * bias_fc * fc_diseno, N, 1);
    fy_muestra = normrnd(bias_fy * fy_diseno, cov_fy * bias_fy * fy_diseno, N, 1);
    b_muestra = normrnd(bias_b * b_diseno, cov_b * bias_b * b_diseno, N, 1);
    d_muestra = normrnd(bias_d * d_diseno, cov_d * bias_d * d_diseno, N, 1);
    As_muestra = normrnd(bias_As * As_diseno, cov_As * bias_As * As_diseno, N, 1);

    % Momento resistente (según fórmula del ACI)
    Mr = resistencia_modelo.* As_muestra .* fy_muestra .* d_muestra .* (1 - (As_muestra .* fy_muestra) ./ ( fc_muestra .* b_muestra .* d_muestra));

    % Momento solicitante (suma de cargas vivas y muertas)
    M_solicitante =( momento_flector_vivo  + momento_flector_muerto ) .* solicitante_modelo;

    % Verificar fallas
    fallas = Mr < M_solicitante;
    porcentaje_fallas = sum(fallas) / N;

    % Confiabilidad
    beta = -norminv(porcentaje_fallas);

    % Guardar resultados
    resultados_fallas(i) = porcentaje_fallas;
    beta_vigas(i) = beta;
    
    % Medir el tiempo de simulación para esta viga y guardarlo
    tiempos_viga(i) = toc;
end

% Medir el tiempo total de simulación 
tiempo_total = toc;

% Mostrar resultados
disp('Porcentaje de fallas por viga:');
disp(resultados_fallas * 100); % En porcentaje

disp('Confiabilidad (beta) por viga:');
disp(beta_vigas);

% Mostrar tiempos
disp('Tiempos de simulación por viga (en segundos):');
disp(tiempos_viga);

disp('Tiempos total de simulación (en segundos):');
disp(tiempo_total);
