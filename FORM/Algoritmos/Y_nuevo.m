function Y_nuevo = Y_nuevo(delta, Y, grad_val_Y, g_de_Y)
    %Algoritmo iHLRF con limitacion para lamda mínimo
    %Parámetros de la regla de Armijo
    a_arm = 0.3;
    b_arm = 0.8;
    gamma = 2;

    % Paso 1: Calcular la dirección de búsqueda d_k
    direccion_busqueda = ((grad_val_Y' * Y - g_de_Y) / norm(grad_val_Y)^2) * grad_val_Y - Y;

    % Paso 2: Determinar el factor de penalidad c_k de la función mérito
    if abs(g_de_Y) >= delta
        % Si |g(y_k)| >= delta
        c_k = gamma * max(norm(Y) / norm(grad_val_Y), 0.5 * norm(Y + direccion_busqueda)^2 / abs(g_de_Y));
    else
        % Si |g(y_k)| < delta
        c_k = gamma * (norm(Y) / norm(grad_val_Y));
    end

    % Función mérito: m(y) = 1/2 * ||y||^2 + c_k * |g(y)|
    merito = @(y) 0.5 * norm(y)^2 + c_k * abs(g_de_Y);

    % Paso 3: Búsqueda lineal para el factor de paso lambda_k
% Inicializar el valor de lamda en 1
lambda = 1;
lambda_optimo = lambda;  % Almacena el último valor de lamda que cumple la condición de Armijo
lambda_minimo = b_arm^2;   % Valor mínimo permitido para lambda


% Realizar la búsqueda lineal para encontrar el mayor lamda que cumpla la condición de Armijo
while true
    % Nuevo punto candidato en Y + lamda * direccion_busqueda
    Y_candidato = Y + lambda * direccion_busqueda;

    % Verificar la condición de Armijo
    if merito(Y_candidato) - merito(Y) <= a_arm * lambda * (grad_val_Y' * direccion_busqueda)
        % Si la condición se cumple, almacenar el valor actual de lamda como óptimo
        lambda_optimo = lambda;
        % Detener la búsqueda, ya que hemos encontrado el mayor lamda que cumple
        break;
    else
        % Reducir lamda si la condición no se cumple
        lambda = lambda * b_arm;
         % Verificar si lambda ha llegado al valor mínimo permitido
          if lambda < lambda_minimo
                lambda = lambda_minimo; % Fijar lambda al valor mínimo permitido
                lambda_optimo = lambda; % Guardar el valor mínimo como óptimo
                break;
          end
    end
end

% Usar el último lamda que cumplió la condición de Armijo
lambda = lambda_optimo;

    % Paso 4: Actualización del punto Y usando el último lamda que cumplió la condición
    Y_nuevo = Y + lambda_optimo * direccion_busqueda;
end
