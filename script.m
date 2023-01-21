

[File,Path] = uigetfile('*.csv','Select the measurement data');%open file browser
full_Path=fullfile(Path,File);

if isequal(File,0)
    return;
end

rawData=readtable(full_Path); %readsData
%clear File Path full_Path;


%% Check if . (dot) is used in decimals
if(~isa(rawData.deltaTInS(1),'double'))
    msgbox(["ERROR!";"File not supported";"Decimals must use a . (dot)"],"Error","error");
    return;
end

%% Check if file contains multiple runs
NewStart=find(rawData.deltaTInS==0);
if (length(NewStart)>1)
    msgbox(["ERROR!";"File contains multiple runs";"Please use Split first"],"Error","error");
    return;
end

%% Check if XSteam is installed
% On Windows folder might not be added automaticaly to MATLAB Path
addons=matlab.addons.installedAddons;
if(~sum(contains(addons.Name, 'X Steam, Thermodynamic properties of water and steam.')) && ~exist('refpropm.m','file')) 
    msgbox(["ERROR!";" XSteam or refprop not found not found";"Please install"],"Error","error");
    return;
end

prompt = {'Average over n Seconds'};
dlgtitle = 'Average';
dims = [1 40];
definput = {'10'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

if isempty(answer)
    return;
end

deltaT=str2double(answer{1});
if deltaT<0.1
    deltaT=0.1;
end
numElAvg=1/0.1*deltaT;


pos_TC_rel=[18 150.3 149.7 149.9 200.5 50.1 49.8 49.4 51.2 49.7]/1000; % [m]
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000; % [m]
sect_lenght=[93.15 150 149.8 175.2 125.3 49.95 49.6 50.3 50.45 46.25]/1000; % [m]
pos_frac=[0.1932 0.501 0.4997 0.4278 0.8001 0.5015 0.502 0.4911 0.5074 0.5373];
r_i=4/1000; % [m]
r_o=5/1000; % [m]
heated_lenght=0.94; % [m]
A_section=2*r_o*pi*sect_lenght; % [m2]

d_o=26.4/1000;
d_i=10/1000;
d_h=d_o-d_i;
ratio=d_i/d_o;
A_h=((d_o/2)^2-(d_i/2)^2)*pi;
totallength=0.94;

totalTime=max(rawData.deltaTInS);



%% Extracts KR temperature Data
temperature_wall=table2array(rawData(:,56:66));
%temperature_wall(:,2)=(temperature_wall(:,1)+temperature_wall(:,3))/2; %% interpolates Temperature as TC is broken
temperature_wall(:,2)=[];
temperature_wall=flip(temperature_wall,2); % flips so that table position matches TC position (1st column = bottom TC)
temperature_wall=blockavg(temperature_wall,numElAvg);


numPoints=height(temperature_wall);
timeVect=linspace(0,totalTime,numPoints)';

%% Extracts and smooths pressure
IO_Pressure(:,1)=blockavg(rawData.DruckVorKRInBar,numElAvg);
IO_Pressure(:,2)=blockavg(rawData.DruckNachKRInBar,numElAvg);
Pressure=IO_Pressure(:,1)+(IO_Pressure(:,2)-IO_Pressure(:,1)).*pos_TC_abs;

%% Various Computations

% Mass flow [kg/s]
densityH20=1;
rawMassFlow=blockavg(rawData.DurchflussInL_min,numElAvg);
MassFlow=densityH20*(rawMassFlow/60); % kg/s

% Heater Power [W]
Voltage=blockavg(rawData.SpannungsabfallKRInV,numElAvg);
Current=blockavg(rawData.GesamtstromInA,numElAvg);
HeaterPower=Current.*Voltage; % W
HeaterSet=blockavg(rawData.VerdampferleistungSollInW,numElAvg);

%% Estimates Resistive Heating at each section in W
% Uses Current and estimated Resistance of each Section
res_Heating=zeros(numPoints,10);
for i=1:10
    res_Heating(:,i)=calc_elPower(Current,temperature_wall(:,i),sect_lenght(i));
end

% validates resistive heating with measured Power
resHeating_sum=sum(res_Heating,2);
resHeating_corrFac=HeaterPower./resHeating_sum;
res_Heating=resHeating_corrFac.*res_Heating;
resHeating_sum=sum(res_Heating,2);
% calculates heat flux [ W/(m2*K) ]
res_Heating_flux=res_Heating./A_section;

therm_Cond=1.7*10^-8*temperature_wall.^3-3.1*10^-5*temperature_wall.^2+3.25*10^-2*temperature_wall+7.52;
temperature_wall_outside=temperature_wall-(r_o*res_Heating_flux)./(2*therm_Cond)+(res_Heating_flux*r_i^2*r_o)./(therm_Cond*(r_o^2-r_i^2))*log(r_o/r_i);

%% Entalpy change over full System in kJ/kg
IO_Temp(:,1)=blockavg(rawData.TemperaturKreisringeintrittIn_C,numElAvg);
IO_Temp(:,2)=blockavg(rawData.TemperaturKreisringaustrittIn_C,numElAvg);
EnthalpyInSet=blockavg(rawData.EintrittsenthalpieInKJ_kg,numElAvg);

IO_Enthalpy=zeros(numPoints,2);
if ispc
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        IO_Enthalpy(i,1)=refpropm('H','T',IO_Temp(i,1)+273.15,'P',Pressure(i,1)*100,'Water')/1000;
        IO_Enthalpy(i,2)=refpropm('H','T',IO_Temp(i,2)+273.15,'P',Pressure(i,2)*100,'Water')/1000;
    end
else
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        IO_Enthalpy(i,1)=XSteam('h_pt',IO_Pressure(i,1),IO_Temp(i,1));
        IO_Enthalpy(i,2)=XSteam('h_pt',IO_Pressure(i,2),IO_Temp(i,2));
    end
end

%% Total Energy Balance
Q_loss=HeaterPower-1000.*MassFlow.*(IO_Enthalpy(:,2)-IO_Enthalpy(:,1));
Efficinecy=MassFlow.*(IO_Enthalpy(:,2)-IO_Enthalpy(:,1))./HeaterPower;

%% enthalpy calculations in kJ/kg
%Enthalpy at each position
Enthalpy=zeros(numPoints,10);
for j=1:10
    Enthalpy(:,j)=IO_Enthalpy(:,1)+...
        (sum(res_Heating(:,1:(j-1)),2)+res_Heating(:,j).*pos_frac(j))./(MassFlow*1000);
end

%% fluid temperature calculation
temperature_fluid=zeros(numPoints,10);
if ispc
    for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints 
            temperature_fluid(i,j)=refpropm('T','P',Pressure(i,j)*100,'H',Enthalpy(i,j)*1000,'Water')-273.15;
        end
    end
else
    for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints 
            temperature_fluid(i,j)=XSteam('T_ph',Pressure(i,j),Enthalpy(i,j));
        end
    end
end

%% Computes Vapour Fraction
VapourFrac=zeros(numPoints,10);
if ispc
    for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints %%needs to be looped as XSteam doesn't accept vectors
            VapourFrac(i,j)=refpropm('Q','P',Pressure(i,j)*100,'H',Enthalpy(i,j)*1000,'Water');
        end
    end
else
    for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints %%needs to be looped as XSteam doesn't accept vectors
            VapourFrac(i,j)=XSteam('x_ph',Pressure(i,j),Enthalpy(i,j));
        end
    end
end


%% Heat Transfer Coefficient Calculation in W/(m2*K)
HTC=res_Heating_flux./(temperature_wall_outside-temperature_fluid);

%% Computation of thermodynamic Properties
dynVisc=zeros(numPoints,10);
isobaricHeatCap=zeros(numPoints,10);
thermalCond=zeros(numPoints,10);
for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints 
        if VapourFrac(i,j)<=0
        [dynVisc(i,j), isobaricHeatCap(i,j), thermalCond(i,j)]=therm_Prop_Calc(Pressure(i,j),temperature_fluid(i,j));
        end
    end
end
Nu_exp=HTC.*d_h./thermalCond;
Pr_exp=dynVisc.*isobaricHeatCap./thermalCond;
Re_exp=MassFlow.*d_h./(dynVisc*A_h);

%% Simulation of HTC
HTC_sim=zeros(numPoints,10);
for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints 
        if VapourFrac(i,j)<=0
            HTC_sim(i,j)=HTC_sim_1P(Pressure(i,j),temperature_wall(i,j),thermalCond(i,j),Re_exp(i,j),Pr_exp(i,j),pos_TC_abs(j));
        else
            HTC_sim(i,j)=HTC_sim_2P(temperature_fluid(i,j),Pressure(i,j),res_Heating(i,j),VapourFrac(i,j),pos_TC_abs(j),MassFlow(i));
        end
    end
end

%% Nusslet Number from LeastSquares Approach
x=[5.194725261478277,0.479405851735662,-0.869964261707776,-0.206645169972858];
Nu_sim_my=x(1)*Re_exp.^x(2).*Pr_exp.^x(3).*pos_TC_abs.^x(4);
HTC_sim_my=Nu_sim_my.*thermalCond/d_h;