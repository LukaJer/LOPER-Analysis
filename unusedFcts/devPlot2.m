close all
size=[1249,451,799,420]; % window size and positions

figure(Position=size)
hold on;
plot(pos_TC_abs,HTC_mean(:,2)/1000,'-o','LineWidth',1,'Color',"#D95319");
plot(pos_TC_abs,HTC_mean(:,3)/1000,'-o','LineWidth',1,'Color',"#EDB120")
plot(pos_TC_abs,HTC_mean(:,4)/1000,'-x','LineWidth',2,'Color',"#D95319")
plot(pos_TC_abs,HTC_mean(:,5)/1000,'-x','LineWidth',2,'Color',"#EDB120")

title('Heat Transfer Coefficient');
ylabel('HTC $$\left[\frac{kW}{m^{2}K}\right]$$',Interpreter='latex',FontSize=12)
xlabel('Position')
legend ("b","c","e","f")
grid;
hold off;

figure(Position=size)
%stem(pos_TC_abs,HTC_dev(:,2:end),'-_','LineWidth',1.5)
hold on;
bar(pos_TC_abs,HTC_dev(:,4:5)); 
ylabel('Deviation $$\left[\zeta\right]$$',Interpreter='latex',FontSize=15);
xlabel('Position')
legend ("e","f")
axis padded
grid on

% table2latex(HTCs,'HTCs');
% table2latex(HTCs_sim,'HTCs_sim');
% table2latex(HTCs_dev,'HTCs_dev');