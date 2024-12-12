function [Beta, Pf, sensibilidad, X, tabla_iteraciones] = FORM(ec_estado_limite, modelos, medias, tol)
% Calcula el índice de confiabilidad Beta, la probabilidad de falla Pf,
% los coeficientes de sensibilidad (sensibilidad), y el punto de proyecto X
% utilizando el Método de Primer Orden (FORM). También devuelve una tabla 
% con los valores de Beta y X en cada iteración.
%
% Entradas:
%   - ec_estado_limite: función que define la ecuación de estado límite
%   - modelos: distribuciones probabilísticas de las variables aleatorias 
%              (normal, log-normal, Gumbel, etc.)
%   - medias: valores medios de las variables
%   - tol: tolerancia para los criterios de convergencia
%
% Salidas:
%   - Beta: índice de confiabilidad final
%   - Pf: probabilidad de falla final
%   - sensibilidad: vector de coeficientes de sensibilidad igual a alpha^2
%   - X: punto de proyecto en el espacio de las variables originales final
%   - tabla_iteraciones: tabla con valores de Beta, X e Y en cada iteración

    % Inicialización de parámetros y punto inicial
    X_0 = medias;  % Punto inicial, corresponde a los valores medios de las variables
    evaluar_g = @(in1) ec_estado_limite(in1);  % Función para evaluar el estado límite en un punto
    A_tol = tol;
    B_tol = tol * abs(evaluar_g(X_0)); % Tolerancia de g depende de la escala de la ecuación de estado límite
    
    % Variables de convergencia y tolerancia
    conv_B = Inf;
    conv_A = Inf;
    max_iteraciones = 100;
       
    % Inicialización de variables
    contador = 1;
    X = X_0;  % Punto inicial en el espacio original
    g_de_Y = evaluar_g(X);  % Evalúa la ecuación de estado límite en el punto
    X_medias_AL = zeros(length(X), 1);  % Vector de medias equivalentes en el espacio normalizado (aproximación lineal)
    X_desvest_AL = zeros(length(X), 1); % Vector de desviaciones estándar equivalentes en el espacio normalizado
    
    % Crear la tabla para almacenar los resultados de cada iteración
    tabla_iteraciones = table();
    
    % Inicio del proceso iterativo
    while contador < max_iteraciones && (conv_A > A_tol || conv_B > B_tol)
        % PASO 1: Aproximación lineal
        % Calcula las medias y desviaciones estándar normales equivalentes
        for cont_var = 1:length(X)
            [X_medias_AL(cont_var), X_desvest_AL(cont_var)] = AproximacionLineal(modelos(cont_var), X(cont_var));
        end
        
        % PASO 2: Transformación al espacio normal (X a Y)
        Y = (X - X_medias_AL) ./ X_desvest_AL;
        
        % PASO 3: Evaluación del gradiente
        grad_val_X = numericGradient(evaluar_g, X,1e-8*min(abs(X)));  % Calcula el gradiente de la ecuación en el espacio original de forma numérica
        
        % PASO 4: Transformación del gradiente al espacio normal
        grad_val_Y = grad_val_X .* X_desvest_AL;  % Utiliza la matriz D para la transformación
        
        % PASO 5: Cálculo de los coeficientes de sensibilidad
        alphas = grad_val_Y / norm(grad_val_Y);  % Calcula el vector unitario de sensibilidad
        
        % PASO 6: Actualización del punto en el espacio normal
        Y = Y_nuevo(B_tol,Y, grad_val_Y, g_de_Y); % Utiliza la función Y_nuevo que usa el algoritmo iHLRF
        
        % PASO 7: re-aproximación lineal
        for cont_var = 1:length(X)
            [X_medias_AL(cont_var), X_desvest_AL(cont_var)] = AproximacionLineal(modelos(cont_var), X(cont_var));
        end
        
        % PASO 8: Transformación inversa al espacio original
        X = X_medias_AL + Y .* X_desvest_AL;
        
        % Paso 9: Re-cálculo del gradiente
        grad_val_X = numericGradient(evaluar_g, X);
        grad_val_Y = grad_val_X .* X_desvest_AL;
         
        % PASO 10: Cálculo del índice de confiabilidad (Beta) y convergencia
        Beta = norm(Y);  % Índice de confiabilidad basado en la distancia al origen en el espacio normal
        conv_A = 1-abs(grad_val_Y'*Y)/(norm(grad_val_Y)*norm(Y));  % Criterio de convergencia de Beta
        g_de_Y = evaluar_g(X); % Actualización de g(y)
        conv_B = abs(g_de_Y);  % Criterio de convergencia de la función de estado límite
        
        % Guardar los resultados de esta iteración en la tabla
        tabla_iteraciones = [tabla_iteraciones; table( ...
    contador, Beta, conv_A, conv_B, ...
    X(1), X(2), X(3), X(4), X(5), X(6), X(7), X(8), X(9), ...
    Y(1), Y(2), Y(3), Y(4), Y(5), Y(6), Y(7), Y(8), Y(9) ...
)];
        
        % Incremento del contador de iteraciones
        contador = contador + 1;
    end
    
    % Cálculo de la probabilidad de falla
    Pf = 1 - normcdf(Beta);
    % Vector de sensibilidad
    sensibilidad = sign(alphas) .* (alphas .^ 2);
    
    % Renombrar las columnas de la tabla
    tabla_iteraciones.Properties.VariableNames = { ...
    'Iteracion', 'Beta', 'conv_A', 'conv_B', ...
    'X1', 'X2', 'X3', 'X4', 'X5', 'X6', 'X7', 'X8', 'X9', ...
    'Y1', 'Y2', 'Y3', 'Y4', 'Y5', 'Y6', 'Y7', 'Y8', 'Y9' ...
};
    
end
