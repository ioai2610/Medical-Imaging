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
E0=120; % keV
phi_0=100; % fotones/mm2

% phantom
r=10; %mm
a=r/delta;
az=a;
label=[2,4]; % elements from compoundList from SPEKTR
phan=def_esfera(N,r,label); % calling phantom form phantoms dir

%%
% Cálculo de la transmisión promedio y muestreo con el detector
P=xray_proj(phan,E0,phi_0,delta,pix_sz);

%% 
% Generar ruido
sigma_p=0.4591/power(phi_0,0.5109);
sigma=sigma_p*P;
noise=noise_generator(NPS,sigma);

%%
% Aplicar la PSF a la transmisión promedio
FWHM=2.5; %mm
sigma_psf=FWHM/(2*sqrt(2*log(2)));
sigma_psf=sigma_psf/delta;
P=imgaussfilt(P,sigma_psf);

%%
% sumar la contribución del ruido
P=P+noise;

%%
% despliegue de la imagen log
I0=mean(P(:,1));
im_log=log(I0)-log(P);
imagesc(im_log);axis image;colormap(gray);