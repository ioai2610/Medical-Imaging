function[S]=def_rand(N,r,label)
    % define una esfera de radio r, uniforme, centrada, en una matríz 
    % de N x N x N
    amplitude = r/3;
    numberOfPoints = 5;
    rotationAngle = 0;
    theta = (0 : (numberOfPoints-1)/numberOfPoints*pi : (numberOfPoints-1)*pi) + rotationAngle;
    S=ones(N,N,N)*label(1);
    if randi([0 1],1,1) == 1
        cx = round(N/2); cy = cx; cz = cx; % centro de matriz
        for i=1:N
            for j=1:N
                for k=1:N
                    x = amplitude .* cos(theta) + (i-cx);
                    y = amplitude .* sin(theta) + (j-cy);
                    z = k-cz;
                    if x < r && y < r && z < r
                        S(i,j,k) = label(2);
                    end
                end
            end
        end
    end
end
