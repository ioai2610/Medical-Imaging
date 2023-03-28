function[P]=xray_proj(phantom,E0,phi0,delta,pix_sz)
    S=spektrSpectrum(E0);
    S=S/sum(S);
    index=find(S);

    A=power(delta,2); 
    N0=phi0*A;
    
    r=delta/pix_sz;

    labels=unique(phantom);
    [mus]=def_mus(labels);

    mus_det=spektrMuRhoCompound(8); 
    x_det=0.45; %mm
    yield=54; %photons per keV

    P=0;
    parfor j=index(1):index(end)
        aux=zeros(size(phantom));
        for k=1:numel(labels)
            aux(phantom==labels(k))=mus(j,k);
        end
        eta=1-exp(-mus_det(j)*x_det);
        n=eta*N0*S(j)*exp(-sum(aux,3)*delta);
        proj=yield*j*poissrnd(n);
        P=P+proj;
    end
    P=imresize(P,r);
end

function[mus]=def_mus(labels)
    for j=1:numel(labels)
        mus(:,j)=spektrMuRhoCompound(labels(j));  
    end
end