function[output]=ls_estimation(input,H_ifft,pilot_sequence)
[N,NL]=size(input);
output=zeros(N,NL);
i=1;
k=1;
H=fft(H_ifft,128)/sqrt(128);
input_tem=fft(input,128)/sqrt(128);
for i=1:1:200
    H_out(:,i)=H(:,i)./(pilot_sequence);
end
q=1;
b=1;
while q<=200
    h=inv(diag(H_out(:,b),0));
    Y=input_tem(:,k:(k+4));
    output(:,k:(k+4))=h*Y;
    k=k+5;
    q=q+1;
    b=b+1;
    
end