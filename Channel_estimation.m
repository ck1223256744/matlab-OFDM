function[output]=Channel_estimation(input,Deletepilot_Data,pilot_seq,H)
if input==1
    output=ls_estimation(Deletepilot_Data,H,pilot_seq);
else
    output=mmse_estimation(Deletepilot_Data,H,pilot_seq);
end
end