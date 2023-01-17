function [] = compST(temp,press)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if ispc
    dynVisc=refpropm('V','T',temp+273.15.15,'P',press*100,'Water') % [Pa*s]
    isobaricHeatCap=refpropm('C','T',temp+273.15,'P',press*100,'Water') % [J/(kg K)]
    thermalCond=refpropm('L','T',temp+273.15,'P',press*100,'Water') %  [W/(m K)]
else
    dynVisc=XSteam('my_pT',press,temp) % in N*s/m2
    isobaricHeatCap=XSteam('Cp_pT',press,temp)*1000 % in J/(kg*K)
    thermalCond=XSteam('tc_pT',press,temp) % W/(m*K)

    dynVisc_CP=py.CoolProp.CoolProp.PropsSI('V','T',temp+273.15,'P',press*100000,'Water')
    isobaricHeatCap_CP=py.CoolProp.CoolProp.PropsSI('C','T',temp+273.15,'P',press*100000,'Water')
    thermalCond_CP=py.CoolProp.CoolProp.PropsSI('L','T',temp+273.15,'P',press*100000,'Water')
end
end