function[P]=xray_proj(phantom,E0,delta)
    S=spektrSpectrum(E0);
    S=S/sum(S(:));
    index=find(S);

    labels=unique(phantom);
    [mus]=def_mus(labels);

    P=0;
    for j=index(1):index(end)
        aux=zeros(size(phantom));
        for k=1:numel(labels)
            aux(phantom==labels(k))=mus(j,k);
        end
        proj=S(j)*exp(-sum(aux,3)*delta);
        P=P+proj;
    end
end

function[mus]=def_mus(labels)
    for j=1:numel(labels)
        mus(:,j)=spektrMuRhoCompound(labels(j));  
    end
end