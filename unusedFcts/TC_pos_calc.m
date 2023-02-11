%% calculations for TC positions

pos_TC_rel=[18*2 150.3 149.7 149.9 200.5 50.1 49.8 49.4 51.2 49.7 21.4*2];
for i=1:10
    length(i)=pos_TC_rel(i)/2+pos_TC_rel(i+1)/2
end

pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6];
pos_TC_rel=flip([18 150.3 149.7 149.9 200.5 50.1 49.8 49.4 51.2 49.7 21.4]);
% lengtl_sec=[21.4*2];
% for i=2:10
%     lengtl_sec(i)=(pos_TC_rel(i)-lengtl_sec(i-1)/2)*2
% end

a=[0 93.1500  243.1500  392.9500  568.1500  693.4500  743.4000  793.0000  843.3000  893.7500];
sect_lenght=[93.15 150 149.8 175.2 125.3 49.95 49.6 50.3 50.45 46.25];
for i=1:10
    length(i)=(pos_TC_abs(i)-a(i))/sect_lenght(i)
end