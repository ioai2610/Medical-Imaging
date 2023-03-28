function[phan]=SL_3d()
    S=round(phantom*10);
    aux=S;
    aux(S<1)=12;
    aux(S==0)=2;
    aux(S==1)=9;
    aux(S==2)=5;
    aux(S==3)=3;
    aux(S==4)=14;
    aux(S==10)=4;
    aux=repmat(aux,[1,1,256]);
    phan=permute(aux,[3 2 1]);
end