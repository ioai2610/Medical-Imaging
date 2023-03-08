clear;close all;clc;
addpath('./SPEKTR');

load('./phantoms/mat_files/esfera_1.mat');
delta=1; %mm
E0=120; %keV

P=xray_proj(S,E0,delta);

imshow(P);