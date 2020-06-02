function [data_outl,data_outQ]=qpsk_modulation(data_in)
Kmod=1/sqrt(2);
L=length(data_in)/2;
data_outl=zeros(1,L);
data_outQ=zeros(1,L);
for k=1:L
    data_outl(k)=Kmod*(1-2*data_in(2*k-1));
    data_outQ(k)=Kmod*(1-2*data_in(2*k));
end