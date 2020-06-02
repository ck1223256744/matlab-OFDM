clc
clear all;
close all;

j=sqrt(-1);
B=1e6;
N=64;
T=N/B;
f=1/T;
fs=4*B;
Ts=1/fs;
sample=T/Ts;

fd = 0;

tau = [0,50,120,200,230,500,1600,2300,5000]/(10^9);
pdb = [-1.0 ,-1.0 , -1.0 , 0, 0 , 0, -3.0,-5.0,-7.0];
chan = rayleighchan(Ts,fd,tau,pdb);
chan.ResetBeforeFiltering=0;

t=linspace(-T/2,T/2,sample);
st=zeros(1,length(t));
for ii=-N/2-1:N/2
    st=st+(1/sqrt(N))*exp(j*2*pi*f*ii*t);
end

figure(1)
freq=linspace(-fs/2,fs/2,length(st));
fft_y=abs(fft(st));
plot(freq*1e-6,20*log(fftshift(fft_y/max(fft_y))));
xlabel('Frenquency(MHz)');
ylabel('PSD(dB)')
title('OFDMÐÅºÅÆµÆ×')
grid on;axis tight;

