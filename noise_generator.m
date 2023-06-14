function[n]=noise_generator(NPS,sigma)
    th=2*pi*rand(size(NPS));
    v0=sqrt(NPS).*(cos(th)+1i*sin(th));
    n=abs(ifft2(v0));

    n=sigma.*n/mean(max(n));
    n=n-mean(n(:));
end