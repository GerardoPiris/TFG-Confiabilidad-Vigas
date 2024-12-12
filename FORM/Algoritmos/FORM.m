function [Beta, Pf, sensibilidad, X, tabla_iteraciones] = FORM(ec_estado_limite, modelos, medias, tol)
% Calcula el �ndice de confiabilidad Beta, la probabilidad de falla Pf,
% los coeficientes de sensibilidad (sensibilidad), y el punto de proyecto X
% utilizando el M�todo de Primer Orden (FORM). Tambi�n devuelve una tabla 
% con los valores de Beta y X en cada iteraci�n.
%
% Entradas:
%   - ec_estado_limite: funci�n que define la ecuaci�n de estado l�mite
%   - modelos: distribuciones probabil�sticas de las variables aleatorias 
%              (normal, log-normal, Gumbel, etc.)
%   - medias: valores medios de las variables
%   - tol: tolerancia para los criterios de convergencia
%
% Salidas:
%   - Beta: �ndice de confiabilidad final
%   - Pf: probabilidad de falla final
%   - sensibilidad: vector de coeficientes de sensibilidad igual a alpha^2
%   - X: punto de proyecto en el espacio de las variables originales final
%   - tabla_iteraciones: tabla con valores de Beta, X e Y en cada iteraci�n

    % Inicializaci�n de par�metros y punto inicial
    X_0 = medias;  % Punto inicial, corresponde a los valores medios de las variables
    evaluar_g = @(in1) ec_estado_limite(in1);  % Funci�n para evaluar el estado l�mite en un punto
    A_tol = tol;
    B_tol = tol * abs(evaluar_g(X_0)); % Tolerancia de g depende de la escala de la ecuaci�n de estado l�mite
    
    % Variables de convergencia y tolerancia
    conv_B = Inf;
    conv_A = Inf;
    max_iteraciones = 100;
       
    % Inicializaci�n de variables
    contador = 1;
    X = X_0;  % Punto inicial en el espacio original
    g_de_Y = evaluar_g(X);  % Eval�a la ecuaci�n de estado l�mite en el punto
    X_medias_AL = zeros(length(X), 1);  % Vector de medias equivalentes en el espacio normalizado (aproximaci�n lineal)
    X_desvest_AL = zeros(length(X), 1); % Vector de desviaciones est�ndar equivalentes en el espacio normalizado
    
    % Crear la tabla para almacenar los resultados de cada iteraci�n
    tabla_iteraciones = table();
    
    % Inicio del proceso iterativo
    while contador < max_iteraciones && (conv_A > A_tol || conv_B > B_tol)
        % PASO 1: Aproximaci�n lineal
        % Calcula las medias y desviaciones est�ndar normales equivalentes
        for cont_var = 1:length(X)
            [X_medias_AL(cont_var), X_desvest_AL(cont_var)] = AproximacionLineal(modelos(cont_var), X(cont_var));
        end
        
        % PASO 2: Transformaci�n al espacio normal (X a Y)
        Y = (X - X_medias_AL) ./ X_desvest_AL;
        
        % PASO 3: Evaluaci�n del gradiente
        grad_val_X = numericGradient(evaluar_g, X,1e-8*min(abs(X)));  % Calcula el gradiente de la ecuaci�n en el espacio original de forma num�rica
        
        % PASO 4: Transformaci�n del gradiente al espacio normal
        grad_val_Y = grad_val_X .* X_desvest_AL;  % Utiliza la matriz D para la transformaci�n
        
        % PASO 5: C�lculo de los coeficientes de sensibilidad
        alphas = grad_val_Y / norm(grad_val_Y);  % Calcula el vector unitario de sensibilidad
        
        % PASO 6: Actualizaci�n del punto en el espacio normal
        Y = Y_nuevo(B_tol,Y, grad_val_Y, g_de_Y); % Utiliza la funci�n Y_nuevo que usa el algoritmo iHLRF
        
        % PASO 7: re-aproximaci�n lineal
        for cont_var = 1:length(X)
            [X_medias_AL(cont_var), X_desvest_AL(cont_var)] = AproximacionLineal(modelos(cont_var), X(cont_var));
        end
        
        % PASO 8: Transformaci�n inversa al espacio original
        X = X_medias_AL + Y .* X_desvest_AL;
        
        % Paso 9: Re-c�lculo del gradiente
        grad_val_X = numericGradient(evaluar_g, X);
        grad_val_Y = grad_val_X .* X_desvest_AL;
         
        % PASO 10: C�lculo del �ndice de confiabilidad (Beta) y convergencia
        Beta = norm(Y);  % �ndice de confiabilidad basado en la distancia al origen en el espacio normal
        conv_A = 1-abs(grad_val_Y'*Y)/(norm(grad_val_Y)*norm(Y));  % Criterio de convergencia de Beta
        g_de_Y = evaluar_g(X); % Actualizaci�n de g(y)
        conv_B = abs(g_de_Y);  % Criterio de convergencia de la funci�n de estado l�mite
        
        % Guardar los resultados de esta iteraci�n en la tabla
        tabla_iteraciones = [tabla_iteraciones; table( ...
    contador, Beta, conv_A, conv_B, ...
    X(1), X(2), X(3), X(4), X(5), X(6), X(7), X(8), X(9), ...
    Y(1), Y(2), Y(3), Y(4), Y(5), Y(6), Y(7), Y(8), Y(9) ...
)];
        
        % Incremento del contador de iteraciones
        contador = contador + 1;
    end
    
    % C�lculo de la probabilidad de falla
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
