% Código de Irving, requiere:
% def_sphere.m
% xray_proj_alternative.m
% Ejecutar el código en bloques para mejor apreciación del funcionamiento

clear;close all;clc;

addpath('./SPEKTR/');
addpath('./phantoms/');

load('./NPS_model/NPS');

%voxel físico
delta=0.5; % mm

% dimensiones de la imagen (detector)
FOV=100; % mm
pix_sz=1; % mm

% tanaño del volumen simulado
z=50;
Nz=z/delta;
N=FOV/delta;

%parámetros de adquisición

E0=[40 100]; % kVp
phantList ={}; % initialize cell to save the images

%% Getting energies at eV from kVp

tempVector = (1:150)'; % temporal vector
Ek=[]; % Ek energy vector
for i=1:length(E0)
    eval(['spec_E',num2str(i),'=spektrSpectrum(E0(',num2str(i),'))']);
    % Normalizing spectrum energies
    eval(['avgSpec_E',num2str(i),'= round((sum(spec_E',num2str(i),'' ...
        '.*tempVector))/sum(spec_E',num2str(i),'))']);
    % saving them into Ek vector
    eval(['Ek(end+1) = avgSpec_E',num2str(i)]);
end
clear i

%% Generating images

for i=1:length(Ek)
    
    P = 0; % phantom restart
    phi_0=1000; % fotones/mm2
    
    % phantom
    r=10; %mm
    a=r/delta;
    az=a;
    label=[20,4]; % elements from compoundList from SPEKTR (WATER & BONE) 
    phan=def_sphere(N,r,label); % calling phantom form phantoms dir
    
    % Cálculo de la transmisión promedio y muestreo con el detector
    % using energies in eV instead of kVp at "xray_proj_alternative" script
    P=xray_proj_alternative(phan,Ek(i),phi_0,delta,pix_sz);
    
    % Generar ruido
    sigma_p=0.4591/power(phi_0,0.5109);
    sigma=sigma_p*P;
    noise=noise_generator(NPS,sigma);
    
    % Aplicar la PSF a la transmisión promedio
    FWHM=2.5; %mm
    sigma_psf=FWHM/(2*sqrt(2*log(2)));
    sigma_psf=sigma_psf/delta;
    P=imgaussfilt(P,sigma_psf);
    
    % sumar la contribución del ruido
    P=P+noise;
    phantList{end+1} = P;

end

clear noise delta az a FWHM sigma_psf P pix_sz phi_0 r z Nz FOV NPS N sigma
clear sigma_p i phan
%% naming the images 

for j=1:length(phantList)
    eval(['newP_',num2str(j),'=cell2mat(phantList(',num2str(j),'))']); 
end
clear j
%% plotting phantoms at two different energies

figure;
subplot(1,2,1);
imagesc(newP_1);
colorbar('southoutside');
subplot(1,2,2);
imagesc(newP_2);
colorbar('southoutside');
figure.Position = [100 100 550 400];
set(gcf,'Name', '2D Comparison - Irving Orlando Ayala Iturbe', ...
    'NumberTitle','off', ...
    'Position',  [100, 100, 1000, 400]); % graph size
%% despliegue de la imagen log

I0_1=mean(newP_1(:,1));
im_log_1=log(I0_1)-log(newP_1); % image (all that's attenuated)
I0_2=mean(newP_2(:,1));
im_log_2=log(I0_2)-log(newP_2); % image (all that's attenuated)
%imagesc(im_log_2);axis image;colormap(gray);

figure;
subplot(1,2,1);
imagesc(im_log_1);
%colormap(gray);
subplot(1,2,2);
imagesc(im_log_2);
%colormap(gray);
figure.Position = [100 100 550 400];
set(gcf,'Name', 'Log image - Irving Orlando Ayala Iturbe', ...
    'NumberTitle','off', ...
    'Position',  [100, 100, 1000, 400]); % graph size

%% solution form

% we're trying to solve the linear system
% (Im E1    Im E2)' = (mu1 E1  mu2 E1  
%                       mu1 E2  mu2 E2)(c1  c2)'

% IM = MU*C

%% Getting att. coeff values at selected energies

% calling att coeff of element 1 (WATER)
[muElement1, rhoElement1]=spektrMuRhoCompound(20);
% calling att coeff of element 2 (BONE)
[muElement2, rhoElement2]=spektrMuRhoCompound(4);

% getting values at selected energies
for i=1:length(Ek)
    eval(['muElement1_E',num2str(i),'=muElement1(Ek(',num2str(i),'))']);
    eval(['muElement2_E',num2str(i),'=muElement2(Ek(',num2str(i),'))']);
end

clear i muElement2 muElement1
%% Coeff. matrix (M)

% M = [a11 a12;b21 b22]

a11 = muElement1_E1/rhoElement1;
a12 = muElement2_E1/rhoElement2;
b21 = muElement1_E2/rhoElement1;
b22 = muElement2_E2/rhoElement2;
M = [a11 a12 ;b21 b22];
M = inv(M); % Computing inverse

%% Solving the linear system

for n=1:length(im_log_1)
    for m=1:length(im_log_1)
        C1(n,m) = [M(1,1) M(1,2)]*[im_log_1(n,m) im_log_2(n,m)]';
        C2(n,m) = [M(2,1) M(2,2)]*[im_log_1(n,m) im_log_2(n,m)]';
    end
end

%% Plotting C's

figure;
subplot(1,2,1);
imagesc(C1);
%colorbar('southoutside');
colormap("gray");
subplot(1,2,2);
imagesc(C2);
%colorbar('southoutside');
colormap("gray");
figure.Position = [100 100 550 400];
set(gcf,'Name', '2D Comparison - Irving Orlando Ayala Iturbe', ...
    'NumberTitle','off', ...
    'Position',  [100, 100, 1000, 400]); % graph size

%%
per1 = C1(50,:);
plot(per1,'--');
hold on
per2 = C2(50,:);
plot(per2,'.');
