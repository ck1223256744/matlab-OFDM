function output=Delete_CP(input,cp_length)
input_temp=reshape(input,144,1200);
[m,n]=size(input_temp);
output=zeros(m-cp_length,n);
for j=1:n
    output(1:(m-cp_length),j)=input_temp((cp_length+1):m,j);
end
end