function [output,count,pilot_seq]=...
    insert_pilot_f (input,pilot_bit,pilot_inter)
[data_outI,data_outQ]=qpsk_modulation(pilot_bit);
pilot_symbol=data_outI+1i*data_outQ;
pilot_seq=reshape(pilot_symbol,128,1);
[N,NL]=size(input);
output=zeros(N,(NL+fix(NL/pilot_inter)));
count=0;
i=1;
while  i<(NL+fix(NL/pilot_inter))
    output(:,i)=pilot_seq;
    count=count+1;
    if count*pilot_inter<=NL
        output(:,(i+1):(i+pilot_inter))=...
        input(:,((count-1)*pilot_inter+1):count*pilot_inter);
    else
        output(:,(i+1):(i+pilot_inter+NL-count*pilot_inter))=...
        input(:,((count-1)*pilot_inter+1):NL);
    end
    i=i+pilot_inter+1
end
end