function Y_nuevo = Y_nuevo(delta, Y, grad_val_Y, g_de_Y)
    %Algoritmo iHLRF con limitacion para lamda m�nimo
    %Par�metros de la regla de Armijo
    a_arm = 0.3;
    b_arm = 0.8;
    gamma = 2;

    % Paso 1: Calcular la direcci�n de b�squeda d_k
    direccion_busqueda = ((grad_val_Y' * Y - g_de_Y) / norm(grad_val_Y)^2) * grad_val_Y - Y;

    % Paso 2: Determinar el factor de penalidad c_k de la funci�n m�rito
    if abs(g_de_Y) >= delta
        % Si |g(y_k)| >= delta
        c_k = gamma * max(norm(Y) / norm(grad_val_Y), 0.5 * norm(Y + direccion_busqueda)^2 / abs(g_de_Y));
    else
        % Si |g(y_k)| < delta
        c_k = gamma * (norm(Y) / norm(grad_val_Y));
    end

    % Funci�n m�rito: m(y) = 1/2 * ||y||^2 + c_k * |g(y)|
    merito = @(y) 0.5 * norm(y)^2 + c_k * abs(g_de_Y);

    % Paso 3: B�squeda lineal para el factor de paso lambda_k
% Inicializar el valor de lamda en 1
lambda = 1;
lambda_optimo = lambda;  % Almacena el �ltimo valor de lamda que cumple la condici�n de Armijo
lambda_minimo = b_arm^2;   % Valor m�nimo permitido para lambda


% Realizar la b�squeda lineal para encontrar el mayor lamda que cumpla la condici�n de Armijo
while true
    % Nuevo punto candidato en Y + lamda * direccion_busqueda
    Y_candidato = Y + lambda * direccion_busqueda;

    % Verificar la condici�n de Armijo
    if merito(Y_candidato) - merito(Y) <= a_arm * lambda * (grad_val_Y' * direccion_busqueda)
        % Si la condici�n se cumple, almacenar el valor actual de lamda como �ptimo
        lambda_optimo = lambda;
        % Detener la b�squeda, ya que hemos encontrado el mayor lamda que cumple
        break;
    else
        % Reducir lamda si la condici�n no se cumple
        lambda = lambda * b_arm;
         % Verificar si lambda ha llegado al valor m�nimo permitido
          if lambda < lambda_minimo
                lambda = lambda_minimo; % Fijar lambda al valor m�nimo permitido
                lambda_optimo = lambda; % Guardar el valor m�nimo como �ptimo
                break;
          end
    end
end

% Usar el �ltimo lamda que cumpli� la condici�n de Armijo
lambda = lambda_optimo;

    % Paso 4: Actualizaci�n del punto Y usando el �ltimo lamda que cumpli� la condici�n
    Y_nuevo = Y + lambda_optimo * direccion_busqueda;
end
