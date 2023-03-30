close all;
% x_min=min(min(HTC_mean(:,2:end)));
% y_min=min(min(HTC_sim_mean(:,2:end)));
% x_max=max(max(HTC_mean(:,2:end)));
% y_max=max(max(HTC_sim_mean(:,2:end)));
% 
% plot([y_min x_max],[y_min x_max]); 
% hold on;
% 
% plot(HTC_mean(:,2),HTC_sim_mean(:,2),'-o','LineWidth',2,'DisplayName','Measurement a'); 
% plot(HTC_mean(:,3),HTC_sim_mean(:,3),'-o','LineWidth',2,'DisplayName','Measurement b');
% plot(HTC_mean(:,4),HTC_sim_mean(:,4),'-o','LineWidth',2,'DisplayName','Measurement c');
% plot(HTC_mean(:,5),HTC_sim_mean(:,5),'-o','LineWidth',2,'DisplayName','Measurement d');
% axis([x_min x_max y_min y_max])
% hold off;
% axis padded
% grid on

size=[1249,451,799,420]; % window size and positions
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000;
figure(Position=size)
semilogy(pos_TC_abs,HTC_mean(:,2:end),'-o','LineWidth',1); hold on;
semilogy(pos_TC_abs,HTC_sim_mean(:,2),'-x','LineWidth',2,'Color',"#0072BD"); 
semilogy(pos_TC_abs,HTC_sim_mean(:,3),'-x','LineWidth',2,'Color',"#D95319"); 
semilogy(pos_TC_abs,HTC_sim_mean(:,4),'-x','LineWidth',2,'Color',"#EDB120"); 
semilogy(pos_TC_abs,HTC_sim_mean(:,5),'-x','LineWidth',2,'Color',"#7E2F8E"); 
ylabel('$$\frac{kW}{m^{2}K}$$',Interpreter='latex',Rotation=0,FontSize=12);
xlabel('Position')
ylim('padded')
hold off;
grid on
legend ("a","b","c","d")

size=[1249,451,799,420]; % window size and positions

figure(Position=size)
%stem(pos_TC_abs,HTC_dev(:,2:end),'-_','LineWidth',1.5)
bar(pos_TC_abs,HTC_dev(:,2:end))
ylabel('$$\zeta$$',Interpreter='latex',Rotation=0,FontSize=15);
xlabel('Position')
legend ("a","b","c","d")
axis padded
grid on