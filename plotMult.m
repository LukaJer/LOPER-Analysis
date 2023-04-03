%% combines multiple steady state files and creates plots and latex tables [Grouped by Variable]
clear
close all

[file,path] = uigetfile('*.mat',...
    'Select One or More Files', ...
    'MultiSelect', 'on');

Temp_wall_mean=[];
Temp_wall_outside_mean=[];
Temp_fluid_mean=[];
HTC_mean=[];
HTC_sim_mean=[];
VapourFrac_mean=[];
Heat_flux_mean=[];
Enthalpy_mean=[];

identifier={};
count = 'a';
ref=zeros(1,4);

%% Read data from selected measurements
for i=1:length(file)
    full_path=path+string(file(i));
    matObj = matfile(full_path);
    Temp_wall_mean=[Temp_wall_mean matObj.Temp_wall_mean];
    Temp_fluid_mean=[Temp_fluid_mean matObj.Temp_fluid_mean];
    Temp_wall_outside_mean=[Temp_wall_outside_mean matObj.Temp_wall_outside_mean];
    HTC_mean=[HTC_mean matObj.HTC_mean];
    HTC_sim_mean=[HTC_sim_mean matObj.HTC_sim_mean];
    VapourFrac_mean=[VapourFrac_mean matObj.VapourFrac_mean];
    Heat_flux_mean=[Heat_flux_mean matObj.Heat_flux_mean];
    Enthalpy_mean=[Enthalpy_mean matObj.Enthalpy_mean];

    identifier(i)=cellstr(count);
    ref(i,1)=matObj.Massflow_mean;
    ref(i,2)=matObj.HeaterPower_mean;
    ref(i,3)=matObj.Pressure_mean;
    ref(i,4)=matObj.EnthalpyIn_mean;
    count = char(count + 1);
end

pos=linspace(1,10,10)';
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000;

ref=table(identifier',file',ref(:,1),ref(:,2),ref(:,3),ref(:,4));
ref.Properties.VariableNames={'Identifier','File','Massflow','Heater Power','Pressure','Enthalpy in'};
fig = uifigure('Position',[500 500 760 360]);
uit = uitable(fig);
uit.Position = [20 20 720 320];
uit.Data = ref;

HTC_dev=(HTC_sim_mean-HTC_mean)./HTC_mean;
Temp_delta_wall=Temp_wall_mean-Temp_wall_outside_mean;
Temp_delta_fluid=Temp_wall_outside_mean-Temp_fluid_mean;

%% add position data
Temp_wall_mean=[pos Temp_wall_mean];
Temp_fluid_mean=[pos Temp_fluid_mean];
Temp_wall_outside_mean=[pos Temp_wall_outside_mean];
HTC_mean=[pos HTC_mean];
VapourFrac_mean=[pos VapourFrac_mean];
Heat_flux_mean=[pos Heat_flux_mean];
HTC_sim_mean=[pos HTC_sim_mean];
HTC_dev=[pos HTC_dev];
Temp_delta_wall=[pos Temp_delta_wall];
Temp_delta_fluid=[pos Temp_delta_fluid];
Enthalpy_mean=[pos Enthalpy_mean];

%% Create tables
% Temps_wall=array2table(round(Temp_wall_mean,3));
% Temps_wall_outside=array2table(round(Temp_wall_outside_mean,3));
% Temps_fluid=array2table(round(Temp_fluid_mean,3));
% HTCs=array2table(round(HTC_mean,3));
% HTCs_sim=array2table(round(HTC_sim_mean,3));
% HTCs_dev=array2table(round(HTC_dev,3));
% VapFracs=array2table(round(VapourFrac_mean,3));
% HeatFluxes=array2table(round(Heat_flux_mean,3));
% Enthalpy=array2table(round(Enthalpy_mean,3));

%% Export to latex
% table2latex(Temps_wall,'Temps_wall');
% table2latex(Temps_wall_outside,'Temps_wall_outside');
% table2latex(Temps_fluid,'Temps_fluid');
% table2latex(HTCs,'HTCs');
% table2latex(HTCs_sim,'HTCs_sim');
% table2latex(HTCs_dev,'HTCs_dev');
% table2latex(VapFracs,'VapFracs');
% table2latex(HeatFluxes,'HeatFluxes');


size=[1249,451,799,420]; % window size and positions

%% Draw figures

%outer Wall Temperature
figure(Position=size)
plot(pos_TC_abs,Temp_wall_outside_mean(:,2:end),'-o','LineWidth',2)
title('Temperature Wall (outside)')
ylabel('°C','rotation',0,'FontSize',12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%fluid Temperature
figure(Position=size)
plot(pos_TC_abs,Temp_fluid_mean(:,2:end),'-o','LineWidth',2)
title('Temperature Fluid')
ylabel('°C','rotation',0,'FontSize',12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%HTC
figure(Position=size)
plot(pos_TC_abs,HTC_mean(:,2:end)/1000,'-o','LineWidth',2)
title('Heat Transfer Coefficient');
ylabel('$$\frac{kW}{m^{2}K}$$',Interpreter='latex',Rotation=0,FontSize=12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%Vapour Fraction
figure(Position=size)
plot(pos,VapourFrac_mean(:,2:end),'-o','LineWidth',2)
title('Vapor Fraction')
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%Heat Flux
figure(Position=size)
plot(pos_TC_abs,Heat_flux_mean(:,2:end)/1000,'-o','LineWidth',2)
title('Heat Flux')
ylabel('$$\frac{kW}{m^2}$$',Interpreter='latex',Rotation=0,FontSize=12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%Temperature delta over wall
figure(Position=size)
plot(pos_TC_abs,Temp_delta_wall(:,2:end),'-o','LineWidth',2)
title('Temperature Delta along Wall')
ylabel('$$K$$',Interpreter='latex',Rotation=0,FontSize=12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;

%Temperature delta Wall fluid
figure(Position=size)
plot(pos_TC_abs,Temp_delta_fluid(:,2:end),'-o','LineWidth',2)
title('Temperature Delta Wall - Fluid')
ylabel('$$K$$',Interpreter='latex',Rotation=0,FontSize=12)
xlabel('Position')
legend(identifier,Location='southeast');
grid;


%% Enthalpy plots
% figure(Position=size)
% hold on;
% Enthalpy_all=[];
% HTC_all=[];
% for i=2:width(Enthalpy_mean)
%     Enthalpy_all=[Enthalpy_all; Enthalpy_mean(:,i) ];
% HTC_all=[HTC_all; HTC_mean(:,i)/1000 ];
% plot(Enthalpy_mean(:,i),HTC_mean(:,i)/1000,'-o','LineWidth',2)
% end
% title('Heat Transfer Coefficient');
% ylabel('$$\frac{kW}{m^{2}K}$$',Interpreter='latex',Rotation=0,FontSize=12)
% xlabel('Enthalpy in $$\frac{kJ}{kg}$$',Interpreter='latex',Rotation=0,FontSize=12)
% legend(identifier,Location='southeast');
% grid;
% hold off;
%
% EnthlHTC=[Enthalpy_all HTC_all];
% EnthlHTC=sortrows(EnthlHTC)