function data_out=P2SConverter(data_inl,data_inQ)
L=length(data_inl);
data_out=zeros(1,2*L);
for k=1:L
    data_out(1,2*k-1)=data_inl(k);
    data_out(1,2*k)=data_inQ(k);
end
end
