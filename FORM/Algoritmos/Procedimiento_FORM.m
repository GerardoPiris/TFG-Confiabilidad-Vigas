%% M�todo FORM para an�lisis de confiabilidad estructural
% Este programa calcula la confiabilidad estructural de las vigas utilizando
% el M�todo de Primer Orden (FORM).
% exporta los resultados de confiabilidad y probabilidad de falla a un
% documento de Resultados y los coeficientes de sensibilidad e iteraciones
% de las vigas que se deseen en otro documento

% Limpiar el entorno
clear; clc;

%% Pedir el n�mero para los archivos de salida
num_archivo = input('Ingrese un n�mero para identificar los archivos de salida: '); % para diferenciar los documentos de salida en caso de multiples analisis

% Generar los nombres de los archivos
nombre_resultados = sprintf('Resultados de FORM caso 1_%d.xlsx', num_archivo); % decidir como se llamar�n los docs de salida
nombre_iteraciones = sprintf('Sensibilidad e iteraciones caso 1_%d.xlsx', num_archivo);

%% Cargar datos de entrada
% Extraer los datos 
filePath = 'Datos de distribuciones_referencia.xlsx'; % indicar el documento con los datos de entrada
% Leer archivos xls
bias_cov = xlsread(filePath, 'bias y CoV para matlab', 'A2:I3'); % extraer factor bias y coeficientes de variaci�n
bias=bias_cov(1,:);
cov=bias_cov(2,:);

% Leer datos de dise�o de las vigas 
valores_diseno = xlsread(filePath, 'Datos vigas para matlab', 'A3:I322'); % indicar rango de celdas con valores de dise�o

vigasTable = readtable(filePath, 'Sheet', 'Datos vigas para matlab', 'ReadVariableNames', false);
variables = vigasTable{2, 1:9}; % Simbolo de las variables

% Determinar cantidad de vigas
num_vigas = size(valores_diseno, 1);

%% Configuraci�n inicial
% Se debe generar la ecuaci�n de estado l�mite de manera simb�lica
% indicar las variables EN ORDEN
% escribir la ecuaci�n de estado l�mite en la variable M
syms R S D L fc fy b d As

% Ecuaci�n de estado l�mite
M = R * As * fy * (d - As * fy / (2 * 0.85 * fc * b)) - S * (D + L);
M_func = matlabFunction(M, 'Vars', {[R; S; D; L; fc; fy; b; d; As]});
limit_func = @(in1) M_func(in1); % sirve para evaluar la ecuaci�n de estado l�mite
% Tolerancia para convergencia
TOL = 1e-5; % elegir la tolerancia

% Preparar almacenamiento de resultados
resultadosFORM = zeros(num_vigas, 2); % Beta y Pf

% Preasignar sensibilidades para las vigas seleccionadas
vigas_seleccionadas = 1:5:num_vigas; % indicar de cuales vigas se quieren guardar las sensibilidades e iteraciones
num_seleccionadas = length(vigas_seleccionadas);
sensibilidades = zeros(num_seleccionadas, length(variables)); % Matriz preasignada

% Contadores para hojas de iteraciones
contador_iteraciones = 1;
hoja_actual = 1;

%% Iterar sobre cada viga
tic;
indice_sensibilidad = 1; % �ndice para almacenar sensibilidades
for i = 1:num_vigas
    % Extraer valores para la viga actual
    viga_actual = valores_diseno(i, :);

    % Crear modelos probabil�sticos
        % se crean objetos de distribuciones para poder operar y usar funciones
        % con ellos
    modelos = repmat(makedist('Normal', 0, 1), length(variables), 1);
    for j = 1:length(variables)   
    media = viga_actual(j) * bias(j);    
    sigma = cov(j) * media;    
        switch variables{j}
            case 'R'
                % Lognormal para R
                zeta_ln = log(1 + (sigma^2) / (media^2));
                lambda_ln = log(media)-1/2*zeta_ln;
                modelos(j) = makedist('Lognormal', 'mu', lambda_ln, 'sigma', sqrt(zeta_ln));
            case 'S'
                % Lognormal para S
                zeta_ln = log(1 + (sigma^2) / (media^2));
                lambda_ln = log(media)-1/2*zeta_ln;
                modelos(j) = makedist('Lognormal', 'mu', lambda_ln, 'sigma', sqrt(zeta_ln));
            case 'L'
                % Gumbel para L
                xi_g=0; %especifica que sea una distribuicon tipo I
                beta_g = sigma * sqrt(6) / pi;
                alfa_g = media - double(eulergamma) * beta_g;
                modelos(j) = makedist('GeneralizedExtremeValue','k',xi_g, 'mu', alfa_g, 'sigma', beta_g);
            otherwise
                % Normal para las dem�s variables
                modelos(j) = makedist('Normal', 'mu', media, 'sigma', sigma);
        end
    end

    % Calcular confiabilidad usando FORM
    [Beta, Pf, sensibilidad, X, tabla_iteraciones] = FORM(limit_func, modelos, viga_actual', TOL);

    % Almacenar resultados principales
    resultadosFORM(i, :) = [Pf*100, Beta]; % las probabilidades ya ser�n dadas en porcentaje

    % Guardar solo las vigas seleccionadas
    if ismember(i, vigas_seleccionadas)
        sensibilidades(indice_sensibilidad, :) = sensibilidad; % Agregar sensibilidad
        % Guardar resultados de iteraciones identificando la viga
        tabla_iteraciones_viga = [table(repmat(i, size(tabla_iteraciones, 1), 1), 'VariableNames', {'Viga'}), tabla_iteraciones];

        % Obtener la �ltima fila con datos en la hoja actual
        try
            [~, ~, raw] = xlsread(nombre_iteraciones, hoja_actual);
            ultima_fila = size(raw, 1); % �ltima fila con datos
        catch
            ultima_fila = 0; % Si no existe, comienza desde la fila 1
        end

        % Escribir los resultados de iteraciones en el archivo
        xlswrite(nombre_iteraciones, [tabla_iteraciones_viga.Properties.VariableNames; table2cell(tabla_iteraciones_viga)], hoja_actual, ['A' num2str(ultima_fila + 1)]);

        % Incrementar el contador de iteraciones y controlar las hojas
        contador_iteraciones = contador_iteraciones + 1;

        if contador_iteraciones > 16
         contador_iteraciones = 1; % Reiniciar el contador
            hoja_actual = hoja_actual + 1; % Avanzar a la siguiente hoja
        end
        
        indice_sensibilidad = indice_sensibilidad + 1; % Avanzar el �ndice
    end
end

timeElapsed = toc;

%% Guardar resultados consolidados
% Crear una nueva tabla con los resultados
    headers = {'Mod Res','Mod Sol','M_muerto', 'M_vivo', 'fc', 'fy', 'b', 'd', 'As', 'porcentaje de falla', 'confiabilidad'};
    datos_resultados = [valores_diseno, resultadosFORM]; % Agregar columnas adicionales
% Escribir en el archivo Excel
    xlswrite(nombre_resultados, headers, 'resultados', 'A1');
    xlswrite(nombre_resultados, datos_resultados, 'resultados', 'A2');
    disp(['Resultados guardados en el archivo: ', nombre_resultados]);

% Crear tabla con sensibilidades y n�meros de viga
    sensibilidadTable = array2table(sensibilidades, 'VariableNames', variables);
    viga_indices = vigas_seleccionadas'; % Vector columna con los �ndices de las vigas
    sensibilidadTable = addvars(sensibilidadTable, viga_indices, 'Before', 1, 'NewVariableNames', 'Viga');

% Guardar en la hoja de sensibilidades
    writetable(sensibilidadTable, nombre_iteraciones, 'Sheet', 'Sensibilidad');
    disp(['Sensibilidad guardada en el archivo: ', nombre_iteraciones]);
    disp(['Iteraciones y sensibilidad guardados en el archivo: ', nombre_iteraciones]);
fprintf('An�lisis completado en %.2f segundos.\n', timeElapsed);
