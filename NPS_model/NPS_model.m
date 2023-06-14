clear; clc;

N=100;
C0 = round(N/2);

r_max = sqrt(2*power(C0,2));
L=5.5;
c=15;

NPS=zeros(N);

for j=1:N
    for k=1:N
        r0=sqrt(power(j-C0,2)+power(k-C0,2));
        x=r0*c/r_max;
        y=exp(x*log(L))/gamma(x+1);
        if isinf(y)==0
            NPS(j,k)=y;
        end
    end
end

figure;imagesc(NPS);axis image;
save('NPS','NPS');