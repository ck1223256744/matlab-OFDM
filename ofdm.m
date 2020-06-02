%========================================
% OFDM传输系统框架
% 信道估计采用ZF（迫零均衡），最小线性二乘法LS
% 没有涉及到带宽或者子载波间隔＿15kHZ＿
% 在基带传输，没有上下变频
% 信道为AWGN+多径
%=======================================
clear all
close all
clc 
disp(' ==== OFDM  SIMULATION  START ====');
disp(' ==== OFDM  SIMULATION  START ===='); 

%% 仿真控制参数
awgn_en = 0;                                %信道模型选择
fd = 300;                                   %朿大多普勒扩展
sta_num = 5;                               %仿真统计次数

%% OFDM信号参数定义与OFDM信号产生
f_delta = 15e3;                              %子载波间隿
num_carriers = 128;                          %子载波数
cp_length = 16;                              %循环前缀长度
pilot_interval  = 5;                         %插入导频间隔
M = 2;                                       %每星座符号比特数，对应QPSK调制
ce_method = 1;                               %信道估计方法＿1或迿2分别对应LS和MMSE
symbol_len = 1000;                           %ofdm符号敿

fft_n = num_carriers;                        %fft点数
num_bit = num_carriers * symbol_len *M ;     %对应比特数据个数，即128*1000*2
pilot_bit_1 = randi([0 1], 1, 256);          %1*256维向量，作为已知导频的bits
OFDM_SNR_BER= zeros(1,31);                   %存储直接解调OFDM误码玿
OFDM_LS_SNR_BER= zeros(1,31);                %存储基于信道估计后的OFDM误码玿
i=1;

%% 多径信道
%信道参数丿36.101协议指定
fs = (num_carriers) * f_delta;
ts = 1/ fs;
tau = [0,50,120,200,230,500,1600,2300,5000]/(10^9);
pdb = [-1.0 ,-1.0 , -1.0 , 0, 0 , 0, -3.0,-5.0,-7.0];
chan = rayleighchan(ts,fd,tau,pdb);
%chan=comm.RayleighChannel;
chan.ResetBeforeFiltering=0;


OFDM_sigbits = sourcebits(num_bit);          %1*256000，发送的OFDM数据
[moddata_outI,moddata_outQ]=qpsk_modulation(OFDM_sigbits);
OFDMmoddata_in_temp = moddata_outI+1i*moddata_outQ;       %1*128000
OFDMmoddata_in = reshape(OFDMmoddata_in_temp,num_carriers,(length(OFDMmoddata_in_temp))/num_carriers);

%% 加导颿
[Insertpilot_out,count,pilot_seq] = insert_pilot_f(OFDMmoddata_in,pilot_bit_1,pilot_interval);

%% IFFT
OFDMmoddata_out = ifft(Insertpilot_out,fft_n)*sqrt(fft_n);             %OFDM调制

%% 加CP
InsertCPdata_out=Insert_CP(OFDMmoddata_out,cp_length);             %144*1200

%% 并串转换，串行传辿
Channel_data = reshape(InsertCPdata_out,1, 172800);
%% 上变颿

%% 经过多径信道
Add_Multipath_data = filter(chan, Channel_data);

%% 经过AWGN信道，SNR可以变化
for SNR  = 0:1:30
    be1 = 0;
    be2 = 0;
    
    frm_cnt = 0;
    while (frm_cnt<sta_num)
        frm_cnt = frm_cnt + 1;
        %% 经过多径信道
        if (awgn_en==1)
            Add_Multipath_data = Channel_data;
        elseif (fd~=0)
            Add_Multipath_data = filter(chan, Channel_data);
        end

        %Add_noise_data = awgn(Add_Multipath_data,SNR,'measured');%SNR可以变化
        Add_noise_data = awgn(Add_Multipath_data,SNR,'measured');%
        %% 下变频，获得基带信号

        %% 去CP
        DeleteCPdata_out=Delete_CP(Add_noise_data,cp_length);
        %% 取出导频矩阵H
        [Deletepilot_Data,H] = Get_pilot(DeleteCPdata_out,pilot_interval);       %H为导频矩阵，128*200
        %% OFDM信号直接解调，没有信道估计后的补偿
        OFDM_Demodulationdata_out_iter1= fft(Deletepilot_Data)/sqrt(fft_n);                   %OFDM解调
        OFDMdemodulationdata_out_1 = reshape(OFDM_Demodulationdata_out_iter1,1,128000);
        [demodulationdata_outI_1,demodulationdata_outQ_1]=qpsk_demodulation(OFDMdemodulationdata_out_1);% 星座逆映尿
        P2Sdata_out_1=P2SConverter(demodulationdata_outI_1,demodulationdata_outQ_1);% OFDM信号第一次直接解调得到的bits 

        %% 信道估计，采用LS或迅MMSE方法
        estimation_output = Channel_estimation(ce_method,Deletepilot_Data,pilot_seq,H)  ;%
        OFDMdemodulationdata_out_2 = reshape(estimation_output,1,128000);
        [demodulationdata_outI_2,demodulationdata_outQ_2]=qpsk_demodulation(OFDMdemodulationdata_out_2);% 星座逆映尿
        P2Sdata_out_2=P2SConverter(demodulationdata_outI_2,demodulationdata_outQ_2);% OFDM信号第一次直接解调得到的bits

        %% 计算错误比特敿
        be1 = be1 + length(find(P2Sdata_out_1~=OFDM_sigbits));
        be2 = be2 + length(find(P2Sdata_out_2~=OFDM_sigbits));
        ber1 = be1 / (num_bit*frm_cnt);
        ber2 = be2 / (num_bit*frm_cnt);
        if (mod(frm_cnt, 10)==0)
            fprintf('SNR=%.1f, frm_cnt=%d, ber_de=%.8f, ber_ls=%.8f\n', SNR, frm_cnt, ber1, ber2);
        end
    end
    fprintf('SNR=%.1f, frm_cnt=%d, ber_de=%.8f, ber_ls=%.8f\n', SNR, frm_cnt, ber1, ber2);
    
    %% 计算误码玿
    OFDM_SNR_BER(i) = ber1;                                    %存储OFDM误码玿
    OFDM_LS_SNR_BER(i) = ber2;                                 %存储OFDM误码玿,LS
    i=i+1;
end
%% 画图
figure(1)  
SNR_1 = 0:1:30;%信噪比从0刿30dB
semilogy(SNR_1, OFDM_SNR_BER,'b-+');%
hold on
semilogy(SNR_1, OFDM_LS_SNR_BER,'r-*');%
grid on
legend('OFDM直接解调误码玿','基于LS均衡后的误码玿')
xlabel('SNR(dB)');
ylabel('BER');
title('不同解调方式的误码率');

aa = 0;






