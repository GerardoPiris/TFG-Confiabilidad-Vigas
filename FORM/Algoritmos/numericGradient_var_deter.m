function [grad] = numericGradient_var_deter(funcion, punto, perturbacion)
    if nargin < 3
        perturbacion = 1E-6; % Valor predeterminado para la perturbación
    else
        perturbacion = min(perturbacion, 1E-6);
    end

    valor_funcion = funcion(punto); % Valor de la función en el punto original
    grad = zeros(length(punto), 1); % Vector para almacenar las derivadas parciales

    for cont_var = 1:length(punto) % Iterar sobre todas las componentes
        if cont_var == 5 % el número indica cual variable es determinística
            grad(cont_var) = 0; % le asigna la derivada igual a 0
        else % Calcular gradiente para las demás componentes
            current_value = punto;
            current_value(cont_var) = current_value(cont_var) * (1 + perturbacion); % Perturba el componente
            grad(cont_var) = (funcion(current_value) - valor_funcion) / ...
                             (current_value(cont_var) * perturbacion); % Derivada parcial
        end
    end
end
