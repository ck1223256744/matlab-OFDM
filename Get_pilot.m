function [output,H]=Get_pilot(input,pilot_interval)
output_temp=zeros(128,1000);
H_temp=zeros(128,200);
k=1;
i=1;
while k<=200
    H_temp(:,k)=input(:,(pilot_interval+1)*i-pilot_interval);
    k=k+1;
    i=i+1;
end
j=2;
q=1;
r=1;
while(q<=1000)
    output_temp(:,q:(q+4))=input(:,j:(j+4));
    q=pilot_interval*r+1;
    j=(pilot_interval+1)*r+2;
    r=r+1;
end
output=output_temp;
H=H_temp;
end
