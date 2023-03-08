function[]=def_esfera(N,r,label,ID)
    % define una esfera de radio r, uniforme, centrada, en una matríz 
    % de N x N x N 
    S=ones(N,N,N)*2;
    for i=1:N
        for j=1:N
            for k=1:N
                x=j-50;
                y=i-50;
                z=k-50;
                rho=sqrt(power(x,2)+power(y,2)+power(z,2));
                if rho<=r
                    S(i,j,k)=label;
                end
            end
        end
    end
    save(['./mat_files/esfera_',num2str(ID),'.mat'],'S');
end
