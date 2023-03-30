function [dynVisc,specificHeatCap,thermalCond] = therm_Prop_Calc(pressure,temp_fluid)
%% Calculates dynamic Viscosity [Pa*s], specific Heat Capacity [J/(kg K)] and the thermal Conductivity of the fluid [W/(m K)]
if ispc
    dynVisc=refpropm('V','T',temp_fluid+273.15,'P',pressure*100,'Water'); % [Pa*s]
    specificHeatCap=refpropm('C','T',temp_fluid+273.15,'P',pressure*100,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','T',temp_fluid+273.15,'P',pressure*100,'Water'); %  [W/(m K)]
else
    dynVisc=XSteam('my_pT',pressure,temp_fluid); % in N*s/m2
    specificHeatCap=XSteam('Cp_pT',pressure,temp_fluid)*1000 ;% in J/(kg*K)
    thermalCond=XSteam('tc_pT',pressure,temp_fluid); % W/(m*K)
    if isnan(dynVisc)
        dynVisc=py.CoolProp.CoolProp.PropsSI('V','T',temp_fluid+273,'P',pressure*100000,'Water');
    end
end