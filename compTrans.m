function t = compTrans()

n0 = input('Ingresa el número de fotones incidentes: ');
n = input('Indique la cantidad de componentes del material: ');
sum = 0;
while n>0
   n = n-1;
   x = input(['Ingresa el espesor del componente ' num2str(n) ' en cm: ']);
   muE = input(['Ingresa el coeficiente de absorción del componente ' num2str(n)]);
   dens = input(['Ingresa la densidad del componente ' num2str(n) ' en g/cm^3: ']);
   mu = muE*dens;
   sum = sum + mu*x;
end

t  = n0*exp(-sum);
fprintf('\n\nLa transmisión compuesta para dicho material es: ');

end