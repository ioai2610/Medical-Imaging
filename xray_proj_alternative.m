% Código de Irving
% Ver nota en proyFin.m

function[P]=xray_proj_alternative(phantom,E0,phi0,delta,pix_sz)
   
   index = E0; % save S indexes

    A=power(delta,2); % delta^2 in A
    N0=phi0*A; % fluence
    
    r=delta/pix_sz;

    labels=unique(phantom); % labels of phantom variable
    [mus]=def_mus(labels); % calling function from line 33

    mus_det=spektrMuRhoCompound(8); % from SPEKTR, getting linear att. coeff from compound list (CsI)
    x_det=0.45; % mm
    yield=54; % photons per keV

    P=0;
    parfor j=index(1):index(end) % parallel "for" computing
        aux=zeros(size(phantom)); % make zeros matrix of phantom var size
        for k=1:numel(labels) % # elements of label
            aux(phantom==labels(k))=mus(j,k); % assingment of mu's where the phantom is on the aux var
        end
        eta=1-exp(-mus_det(j)*x_det); % fraction of photons that don't attenuate
        n=eta*N0*exp(-sum(aux,3)*delta); % beer-lambert's law
        %proj=yield*j*poissrnd(n);
        proj=yield*j*n; % Scintilliator cristal efficiency
        P=P+proj;
    end
    P=imresize(P,r,'nearest');
end

function[mus]=def_mus(labels)
    for j=1:numel(labels) % number of elements of label variable
        mus(:,j)=spektrMuRhoCompound(labels(j));  % from SPEKTR, get linear attenuation coefficient
    end
end