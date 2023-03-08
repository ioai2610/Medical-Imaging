function t = simpleTrans()

name = input('Ingresa el nombre del material: ', 's');
n0 = input('Ingresa el número de fotones incidentes: ');
x = input('Ingresa el espesor del material: ');
muE = input('Ingresa el coeficiente de absorción del material: ');
dens = input('Ingresa la densidad del material en g/cm^3: ');

mu = muE*dens;
t  = n0*exp(-mu*x);

fprintf('\n\nLa transmisión simple para el %s es: ',name);

end
