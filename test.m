clear;close all;clc;
addpath('/MATLAB Drive/xray_sim/SPEKTR');
addpath('/MATLAB Drive/xray_sim/phantoms');

FOV=200; %mm
delta=0.5; %mm
pix_sz=1; %mm
r=50; %mm
E0=120; %keV
phi_0=100; %fotones/mm2

N=FOV/delta;
nr=r/delta;
label=20;
phan=def_esfera(N,nr,label);

%%
P=xray_proj(phan,E0,phi_0,delta,pix_sz);

%%
FWHM=2; %mm
sigma=FWHM/(2*sqrt(2*log(2)));
sigma=sigma/delta;
P=imgaussfilt(P,sigma);

%%
I0=mean(P(:,1));
figure;imagesc(P);
figure;imagesc(log(I0)-log(P));
