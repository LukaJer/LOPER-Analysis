

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
if(~sum(contains(addons.Name, 'X Steam, Thermodynamic properties of water and steam.')) || ~exist('refpropm.m','file')) 
    msgbox(["ERROR!";" XSteam or refprop not found not found";"Please install"],"Error","error");
    return;
end

totalTime=max(rawData.deltaTInS);
numPoints=height(rawData);

pos_TC_rel=[18 150.3 149.7 149.9 200.5 50.1 49.8 49.4 51.2 49.7]/1000; % [m]
pos_TC_abs=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000; % [m]
sect_lenght=[93.15 150 149.8 175.2 125.3 49.95 49.6 50.3 50.45 46.25]/1000; % [m]
pos_frac=[0.1932 0.501 0.4997 0.4278 0.8001 0.5015 0.502 0.4911 0.5074 0.5373]; % [m]
r_i=4/1000; % [m]
r_o=5/1000; % [m]
heated_lenght=0.94; % [m]
A_section=2*r_o*pi*sect_lenght; % [m2]


%% Extracts KR temperature Data
temperature_wall=table2array(rawData(:,56:66));
%temperature_wall(:,2)=(temperature_wall(:,1)+temperature_wall(:,3))/2; %% interpolates Temperature as TC is broken
temperature_wall(:,2)=[];
temperature_wall=flip(temperature_wall,2); % flips so that table position matches TC position (1st column = bottom TC)



%% Extracts and smooths pressure
IO_Pressure(:,1)=movmean(rawData.DruckVorKRInBar,10);
IO_Pressure(:,2)=movmean(rawData.DruckNachKRInBar,10);
Pressure=zeros(numPoints,10);
for i=1:10
    Pressure(:,i)=IO_Pressure(:,1)+(IO_Pressure(:,2)-IO_Pressure(:,1))*pos_TC_abs(i);
end

%% Various Computations

% Mass flow [kg/s]
densityH20=1;
MassFlow=densityH20*(rawData.DurchflussInL_min/60); % kg/s

% Heater Power [W]
HeaterPower=rawData.GesamtstromInA.*rawData.SpannungsabfallKRInV; % W

%% Estimates Resistive Heating at each section in W
% Uses Current and estimated Resistance of each Section
res_Heating=zeros(numPoints,10);
for i=1:10
    res_Heating(:,i)=calc_elPower(rawData.GesamtstromInA,temperature_wall(:,i),sect_lenght(i));
end

% validates resistive heating with measured Power
resHeating_sum=sum(res_Heating,2); % Validity check, not used;
resHeating_corrFac=HeaterPower./resHeating_sum;
res_Heating=resHeating_corrFac.*res_Heating;
resHeating_sum=sum(res_Heating,2);
% calculates heat flux [ W/(m2*K) ]
res_Heating_flux=res_Heating./A_section;

therm_Cond=1.7*10^-8*temperature_wall.^3-3.1*10^-5*temperature_wall.^2+3.25*10^-2*temperature_wall+7.52;
temperature_wall_outside=temperature_wall-(r_o*res_Heating_flux)./(2*therm_Cond)+(res_Heating_flux*r_i^2*r_o)./(therm_Cond*(r_o^2-r_i^2))*log(r_o/r_i);

%% Entalpy change over full System in kJ/kg
IO_Enthalpy=zeros(numPoints,2);
if ispc
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        IO_Enthalpy(i,1)=refpropm('H','T',rawData.TemperaturKreisringeintrittIn_C(i)+273.15,'P',Pressure(i,1)*100,'Water')/1000;
        IO_Enthalpy(i,2)=refpropm('H','T',rawData.TemperaturKreisringaustrittIn_C(i)+273.15,'P',Pressure(i,2)*100,'Water')/1000;
    end
else
    for i=1:numPoints %needs to be looped refprop/XSteam don't accept vectors
        IO_Enthalpy(i,1)=XSteam('h_pt',IO_Pressure(i,1),rawData.TemperaturKreisringeintrittIn_C(i));
        IO_Enthalpy(i,2)=XSteam('h_pt',IO_Pressure(i,2),rawData.TemperaturKreisringaustrittIn_C(i));
    end
end

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

HTC=zeros(numPoints,10);
for i=1:10
    HTC(:,i)=res_Heating_flux(:,i)./(temperature_wall_outside(:,i)-temperature_fluid(:,i));
end

HTC_sim=zeros(numPoints,10);
for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints 
        if VapourFrac(i,j)<=0
            HTC_sim(i,j)=HTC_sim_1P(MassFlow(i),Pressure(i,j),temperature_fluid(i,j),temperature_wall(i,j),pos_TC_abs(j));
        else
            HTC_sim(i,j)=HTC_sim_2P(temperature_fluid(i,j),Pressure(i,j),res_Heating(i,j),VapourFrac(i,j),pos_TC_abs(j),MassFlow(i));
        end
    end
end

x=[5.194725261478277,0.479405851735662,-0.869964261707776,-0.206645169972858];

HTC_sim_my=zeros(numPoints,10);
for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints 
        if ~VapourFrac(i,j)
            HTC_sim_my(i,j)=HTC_Calc_1P_my(MassFlow(i),Pressure(i,j),temperature_fluid(i,j),temperature_wall(i,j),pos_TC_abs(j),x);
        end
    end
end

Re_exp=zeros(numPoints,10);
Pr_exp=zeros(numPoints,10);
Nu_exp=zeros(numPoints,10);

for j=1:10 %needs to be looped refprop/XSteam don't accept vectors
    for i=1:numPoints 
        if VapourFrac(i,j)<=0
        [Pr_exp(i,j), Re_exp(i,j), Nu_exp(i,j)]=Pr_Re_Nu_calc(Pressure(i,j),temperature_fluid(i,j),MassFlow(i),HTC(i,j));
        end
    end
end

Q_loss=HeaterPower-1000.*MassFlow.*(IO_Enthalpy(:,2)-IO_Enthalpy(:,1));
Efficinecy=MassFlow.*(IO_Enthalpy(:,2)-IO_Enthalpy(:,1))./HeaterPower;


deviation=(HTC-HTC_sim_my)./HTC;
deviation=movmean(deviation,20);
%                 for i=1:length(tempdiff)
%                     rem_sum=sum(tempdiff(i:end,:));
%                     if max(abs(rem_sum))<limit
%                         break;
%                     end
%                 end
%
%                 if i<length(app.temperature_wall) && i<0.9*length(tempdiff)
%                     max_temp_wall=mean(app.temperature_wall(i:end,:))+limit;
%                     min_temp_wall=mean(app.temperature_wall(i:end,:))-limit;
%                     A=app.temperature_wall(i:end,:)<max_temp_wall;
%                     B=app.temperature_wall(i:end,:)>min_temp_wall;
%
%                     C=A.*B;
%                     if length(find(C==0))<1
%                         app.EditField_7.Value=i/10;
%                         return;
%
%                     end
%                 end
%                 app.EditField_7.Value=Inf;