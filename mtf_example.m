clear;clc;

FWHM=2.5; %mm
FOV=100; %mm
sigma=FWHM/(2*sqrt(2*log(2)));

pix_size=1; %mm
sigma=sigma/pix_size;

N=FOV/pix_size;

PSF=zeros(N);PSF(round(N/2),round(N/2))=1;
PSF=imgaussfilt(PSF,sigma);

MTF=abs(fftshift(fft2(PSF)));
imagesc(MTF);axis image;

