function [norm_mean_approx,norm_std_approx]=AproximacionLineal(cdf_model,val)
%recibe la cdf de la variable y un vector de valores de la misma
%devuelve las medias y desviaciones normales equivalentes para dichos valores
    norm_std_approx=zeros(length(val),1);
    norm_mean_approx=zeros(length(val),1);
    for counti=1:length(val)
        Fx_val=cdf(cdf_model,val(counti));%calcula el cdf en el valor val(counti)
        fx_val=pdf(cdf_model,val(counti));%calcula el pdf en el valor val(counti)
        norm_std_approx(counti)=(normpdf(norminv(Fx_val)))/(fx_val);%calcula la desviación estándar normal equivalente 
        norm_mean_approx(counti)=val(counti)-norm_std_approx(counti)*norminv(Fx_val);%calcula la media normal equivalente 
    end
end