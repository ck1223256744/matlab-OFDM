function output=Insert_CP(input,cp_length)
[m,n]=size(input);
output=zeros(m+cp_length,n);
for j=1:n
    output(1:cp_length,j)=input((m-cp_length+1):m,j);
    output((cp_length+1):(m+cp_length),j)=input(:,j);
end
end