function[S]=def_disco(N,r,label)
    % define una esfera de radio r, uniforme, centrada, en una matríz 
    % de N x N x N
    Nz=2*r+20;
    S=ones(N,N,Nz)*2;
    cx=round(N/2);
    cy=cx;
    cz=round(Nz/2);
    for i=1:N
        for j=1:N
            x=j-cx;
            y=i-cy;
            rho=sqrt(power(x,2)+power(y,2));
            if rho<=r
                S(i,j,cz+1)=label;
            end
        end
    end
end