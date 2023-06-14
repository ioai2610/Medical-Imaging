% Código de Irving
% Ver nota en proyFin.m

function[S]=def_sphere(N,r,label)
    % define una esfera de radio r, uniforme, centrada, en una matríz 
    % de N x N x N
    S=ones(N,N,N)*label(1);
    cx=round(N/2);
    cy=cx;
    cz=cx;
    for i=1:N
        for j=1:N
            for k=1:N
                x=j-cx;
                y=i-cy;
                z=k-cz;
                rho=sqrt(power(x,2)+power(y,2)+power(z,2));
                if rho<=r
                    S(i,j,k)=label(2);
                end
            end
        end
    end
end
