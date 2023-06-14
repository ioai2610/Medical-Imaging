function[phan]=def_bloque(N,Nz,a,label)
phan=ones(N,N,Nz)*label(1);
cx=round(N/2);
cy=cx;
cz=round(Nz/2);

phan(cy:cy+a,cx:cx+a,cz:cz+a)=label(2);

end