if ~exist('GUI','var')
    clear

%% Check if XSteam or refprop is installed
% On Windows folder might not be added automaticaly to MATLAB Path
if ispc
    if ~exist('refpropm.m','file')
        msgbox(["ERROR!";"refprop not found";"Please add to path or install"],"Error","error");
        return;
    end
else
    addons=matlab.addons.installedAddons;
    if~sum(contains(addons.Name, 'X Steam, Thermodynamic properties of water and steam.'))
        msgbox(["ERROR!";" XSteam not found";"Please install"],"Error","error");
        return;
    end
    clear addons
end
if ~contains(struct2array(ver), 'Statistics and Machine Learning Toolbox')
        msgbox(["ERROR!";" Statistics and Machine Learning Toolbox reqired"],"Error","error");
        return;
end
if ~contains(struct2array(ver), 'Image Processing Toolbox')
        msgbox(["ERROR!";"Image Processing Toolbox required"],"Error","error");
        return;
end


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
clear NewStart
end

%% Asks for Averaging Timespan
prompt = {'Average over n Seconds'};
dlgtitle = 'Average';
dims = [1 40];
definput = {'10'};
answer = inputdlg(prompt,dlgtitle,dims,definput);
clear prompt dlgtitle dims definput

if isempty(answer)
    return;
end

deltaT=str2double(answer{1});
if deltaT<0.1
    deltaT=0.1;
end
clear answer
numElAvg=1/0.1*deltaT;


%% Definitions
pos_TC_rel=[18 150.3 149.7 149.9 200.5 50.1 49.8 49.4 51.2 49.7]/1000; % [m]
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000; % [m]
sect_lenght=[93.15 150 149.8 175.2 125.3 49.95 49.6 50.3 50.45 46.25]/1000; % [m]
pos_frac=[0.1932 0.501 0.4997 0.4278 0.8001 0.5015 0.502 0.4911 0.5074 0.5373];
r_i=4/1000; % [m]
r_o=5/1000; % [m]
heated_lenght=0.94; % [m]
A_section=2*r_o*pi*sect_lenght; % [m2]
d_gw=26.4/1000; % glass tube inner wall
d_hw=10/1000; % heater outer wall
d_h=d_gw-d_hw;
ratio=d_hw/d_gw;
A_h=((d_gw/2)^2-(d_hw/2)^2)*pi;
totallength=0.94;

totalTime=max(rawData.deltaTInS);



%% Extracts KR temperature Data
Temp_wall=table2array(rawData(:,56:66)); 
Temp_wall(:,2)=[];
Temp_wall=flip(Temp_wall,2); % flips so that table position matches TC position (1st column = bottom TC)
Temp_wall=blockavg(Temp_wall,numElAvg);

%% #sections are taken from #columns in Temp_wall
numPoints=height(Temp_wall); % #time-steps
numSect=width(Temp_wall); % #sections or #TCs
timeVect=round(linspace(0,totalTime,numPoints)',1); % creates new time vector 

%% Extracts and smooths pressure
Pressure_IO(:,1)=blockavg(rawData.DruckVorKRInBar,numElAvg); % input pressure
Pressure_IO(:,2)=blockavg(rawData.DruckNachKRInBar,numElAvg); % output pressure
Pressure=Pressure_IO(:,1)+(Pressure_IO(:,2)-Pressure_IO(:,1)).*pos_TC_abs;

%% Various Computations

% Mass flow [kg/s]
densityH20=1;
MassFlow=blockavg(rawData.DurchflussInL_min,numElAvg);
MassFlow=densityH20*(MassFlow/60); % kg/s
clear densityH20

% Heater Power [W]
Voltage=blockavg(rawData.SpannungsabfallKRInV,numElAvg);
Current=blockavg(rawData.GesamtstromInA,numElAvg);
HeaterPower=Current.*Voltage; % W
HeaterSet=blockavg(rawData.VerdampferleistungSollInW,numElAvg);

%% Estimates Resistive Heating at each section in W
% Uses Current and estimated Resistance of each Section
res_Heating=zeros(numPoints,numSect);
for i=1:numSect
    res_Heating(:,i)=calc_elPower(Current,Temp_wall(:,i),sect_lenght(i));
end

% validates resistive heating with measured Power
resHeating_sum=sum(res_Heating,2);
resHeating_corrFac=HeaterPower./resHeating_sum;
res_Heating=resHeating_corrFac.*res_Heating;
resHeating_sum=sum(res_Heating,2);
Heat_flux=res_Heating./A_section; % calculates heat flux [ W/(m2*K) ]

thermCond_Steel=1.7*10^-8*Temp_wall.^3-3.1*10^-5*Temp_wall.^2+3.25*10^-2*Temp_wall+7.52;
Temp_wall_outside=Temp_wall-(r_o*Heat_flux)./(2*thermCond_Steel)+(Heat_flux*r_i^2*r_o)./(thermCond_Steel*(r_o^2-r_i^2))*log(r_o/r_i);

%% Entalpy change over full System in kJ/kg
Temp_fluid_IO(:,1)=blockavg(rawData.TemperaturKreisringeintrittIn_C,numElAvg);
Temp_fluid_IO(:,2)=blockavg(rawData.TemperaturKreisringaustrittIn_C,numElAvg);
EnthalpyInSet=blockavg(rawData.EintrittsenthalpieInKJ_kg,numElAvg);

Enthalpy_IO=zeros(numPoints,2);
if ispc
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        Enthalpy_IO(i,1)=refpropm('H','T',Temp_fluid_IO(i,1)+273.15,'P',Pressure_IO(i,1)*100,'Water')/1000;
        Enthalpy_IO(i,2)=refpropm('H','T',Temp_fluid_IO(i,2)+273.15,'P',Pressure_IO(i,2)*100,'Water')/1000;

    end
else
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        Enthalpy_IO(i,1)=XSteam('h_pt',Pressure_IO(i,1),Temp_fluid_IO(i,1));
        if isnan(Enthalpy_IO(i,2))
            Enthalpy_IO(i,2)=py.CoolProp.CoolProp.PropsSI('H','T',temp_fluid+273,'P',pressure*100000,'Water');
        end

        Enthalpy_IO(i,2)=XSteam('h_pt',Pressure_IO(i,2),Temp_fluid_IO(i,2));
    end
end

%% Total Energy Balance
Q_loss=HeaterPower-1000.*MassFlow.*(Enthalpy_IO(:,2)-Enthalpy_IO(:,1));
Efficinecy=MassFlow.*(Enthalpy_IO(:,2)-Enthalpy_IO(:,1))./HeaterPower;

%% enthalpy calculations in kJ/kg
%Enthalpy at each position
Enthalpy=zeros(numPoints,numSect);
for j=1:numSect
    Enthalpy(:,j)=Enthalpy_IO(:,1)+...
        (sum(res_Heating(:,1:(j-1)),2)+res_Heating(:,j).*pos_frac(j))./(MassFlow*1000);
end

%% fluid temperature calculation
Temp_fluid=zeros(numPoints,numSect);
if ispc
    for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints
            Temp_fluid(i,j)=refpropm('T','P',Pressure(i,j)*100,'H',Enthalpy(i,j)*1000,'Water')-273.15;
        end
    end
else
    for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints
            Temp_fluid(i,j)=XSteam('T_ph',Pressure(i,j),Enthalpy(i,j));
        end
    end
end

%% Computes Vapour Fraction
VapourFrac=zeros(numPoints,numSect);
if ispc
    for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints %%needs to be looped as XSteam doesn't accept vectors
            VapourFrac(i,j)=refpropm('Q','P',Pressure(i,j)*100,'H',Enthalpy(i,j)*1000,'Water');
        end
    end
    VapourFrac(VapourFrac<0)=0; %sets te Vapor Fraction of subcooled water to 0
else
    for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
        for i=1:numPoints %%needs to be looped as XSteam doesn't accept vectors
            VapourFrac(i,j)=XSteam('x_ph',Pressure(i,j),Enthalpy(i,j));
        end
    end
end


%% Heat Transfer Coefficient Calculation in W/(m2*K)
HTC=Heat_flux./(Temp_wall_outside-Temp_fluid);

%% Computation of thermodynamic Properties
dynVisc=zeros(numPoints,numSect);
specHeatCap=zeros(numPoints,numSect);
thermCond=zeros(numPoints,numSect);
for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints
        if ~VapourFrac(i,j) % only for 1-Phase
            [dynVisc(i,j), specHeatCap(i,j), thermCond(i,j)]=therm_Prop_Calc(Pressure(i,j),Temp_fluid(i,j));
        end
    end
end



%% Dimensionless Numbers
Nu_exp=HTC.*d_h./thermCond;
Pr=dynVisc.*specHeatCap./thermCond;
Re=MassFlow.*d_h./(dynVisc*A_h);

%% Simulation of HTC
HTC_sim=zeros(numPoints,numSect);
for j=1:numSect %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints
        if ~VapourFrac(i,j)
            HTC_sim(i,j)=HTC_sim_1P(Re(i,j),Pr(i,j),pos_TC_abs(j),thermCond(i,j));
        else
            HTC_sim(i,j)=HTC_sim_2P(Pressure(i,j),Heat_flux(i,j),VapourFrac(i,j),pos_TC_abs(j),MassFlow(i));
        end
    end
end

clear i j