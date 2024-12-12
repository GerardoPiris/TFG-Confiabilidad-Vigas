function [grad]=numericGradient(funcion, punto, perturbacion)
    % Datos de entrada: función a evaluar gradiente (simbolica), punto de
    % evaluación, perturbación o variación
    if nargin<3
        perturb=1E-6; % si no se define perturb se le asigna ese valor
    else
        perturb=min(perturbacion,1E-6);
    end
    valor_funcion=funcion(punto); % se calcula el valor de la funcion en el punto
    grad=zeros(length(punto),1); % este vector almacenará las derivadas parciales
    for cont_var=1:length(punto) % para cada componente del vector
        current_value=punto;
        current_value(cont_var)=current_value(cont_var)*(1+perturb); % se varia un poco el componente del vector
        grad(cont_var)=(funcion(current_value)-valor_funcion)/(current_value(cont_var)*perturb); % se calcula la variacion proporcional de la funcion
    end
    
end