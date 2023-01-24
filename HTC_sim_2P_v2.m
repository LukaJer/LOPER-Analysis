function HTC = HTC_sim_2P_v2(pressure,vapourFrac,temp_wall_outside,massflow)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

p_c=220.64; % bar
d_o=26.4/1000;
d_i=10/1000;
d_h=d_o-d_i;
A=((d_o/2)^2-(d_i/2)^2)*pi;

if ispc
    dynVisc=refpropm('V','T',temp_wall_outside+273.15,'P',pressure*100,'Water'); % [Pa*s]
    isobaricHeatCap=refpropm('C','T',temp_wall_outside+273.15,'P',pressure*100,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','T',temp_fluid+273.15,'P',pressure*100,'Water'); %  [W/(m K)]
else
dynVisc=py.CoolProp.CoolProp.PropsSI('V','P',pressure*100000,'Q',0,'Water'); % in Pa s
isobaricHeatCap=py.CoolProp.CoolProp.PropsSI('C','P',pressure*100000,'Q',0,'Water'); % [J/(kg K)]
thermalCond=py.CoolProp.CoolProp.PropsSI('L','P',pressure*100000,'Q',0,'Water'); % [W/(m K)]
p_sat=XSteam('psat_T',temp_wall_outside);
end
Pr_l=dynVisc*isobaricHeatCap/thermalCond;
Re_l0=massflow*d_h/(dynVisc*A)*(1-vapourFrac);

Nu=0.023*Re_l0^0.8*Pr_l^0.4*((1-vapourFrac)^0.8+(3.8*vapourFrac^0.76*(1-vapourFrac)^0.04)/((p_sat/p_c)^0.38));

HTC=Nu*thermalCond/d_h;


end
