clear;clc;close all;

filename='amd256a_atn_1.tif';

N=1024;
level=[0.034 0.037 0.045];

tstack  = Tiff(filename);
[I,J] = size(tstack.read());
K = length(imfinfo(filename));
data = zeros(I,J,K);
data(:,:,1)  = tstack.read();
for n = 2:K
    tstack.nextDirectory()
    data(:,:,n) = tstack.read();
end

data=imquantize(data,level)-1;

data=data(:,:,1:415);
[a,b,c]=size(data);
data = imresize3(data,[N,N,c],'nearest');

data=permute(data,[3,1,2]);
cont=1;
for j=1:10:c-9
    aux=data(j:j+9,:,:);
    writeNPY(aux,['./output/ncat_sec',num2str(cont),'.npy']);
    cont=cont+1;
end



