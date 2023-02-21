
close all;
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000;


%% shows plots from steady state export
% plot(Temp_wall_mean,pos_TC_abs,"-o"); hold on;
% plot(Temp_wall_outside_mean,pos_TC_abs,"-o");
% plot(Temp_fluid_mean,pos_TC_abs,"-o");
% legend('T_{pipe}','T_{pipe outside}','T_{fluid}');
% ylabel('Position');
% xlabel('°C')
% title('Temperature');
% xlim('padded')
% ylim('tight')
% grid;
% hold off;
% 
% figure;
% plot(Heat_flux_mean,pos_TC_abs,"-o");
% ylabel('Position');
% xlabel('$$\frac{W}{m^{2}}$$',Interpreter='latex')
% title('Heat Flux');
% xlim('padded')
% ylim('tight')
% grid;
% 
% figure;
% plot(HTC_mean,pos_TC_abs,"-o");
% legend('HTC_{meas}');
% xlabel('$$\frac{W}{m^{2}K}$$',Interpreter='latex');
% ylabel('Position');
% xlim('padded')
% ylim('tight')
% title('Heat Transfer Coefficient');
% grid;

%% creates summary table form data
HTC_dev=(HTC_sim_mean-HTC_mean)./HTC_mean;
summary=table(linspace(1,10,10)',round(Temp_wall_mean,3),round(Temp_wall_outside_mean,3), round(Temp_fluid_mean,3),...
    round(Heat_flux_mean/1000,3), round(VapourFrac_mean,3),round(HTC_mean/1000,3),round(HTC_sim_mean/1000,3),HTC_dev);
summary.Properties.VariableNames={'pos','Temp_wall','Temp_wall_outside', 'Temp_fluid', 'Heat_flux','VapourFrac','HTC_meas','HTC_sim','HTC_dev'};
table2latex(summary,'summary')

%% creates table with temperatures and temperature diffs
% temps=table(linspace(1,10,10)',round(Temp_wall_mean,3),round(Temp_wall_outside_mean,3), round(Temp_fluid_mean,3));
% temps.Properties.VariableNames={'pos','Temp_wall','Temp_wall_outside', 'Temp_fluid'};
% diff=table(linspace(1,10,10)',round(Temp_wall_mean,3)-round(Temp_wall_outside_mean,3), round(Temp_wall_outside_mean,3)-round(Temp_fluid_mean,3));
% diff.Properties.VariableNames={'pos','Delta T1','Delta T2'};
% table2latex(flip(temps),'temps')
% table2latex(flip(diff),'diff')

