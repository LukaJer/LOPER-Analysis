function [Pr,Re, Nu] = Pr_Re_Nu_calc(pressure,temp_fluid,massflow,HTC)
%% Calculates Re, Pr, Nu from the experimental data
d_o=26.4/1000;
d_i=10/1000;
d_h=d_o-d_i;
ratio=d_i/d_o;
A=((d_o/2)^2-(d_i/2)^2)*pi;

if ispc
    dynVisc=refpropm('V','T',temp_fluid+273.15,'P',pressure*100,'Water'); % [Pa*s]
    isobaricHeatCap=refpropm('C','T',temp_fluid+273.15,'P',pressure*100,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','T',temp_fluid+273.15,'P',pressure*100,'Water'); %  [W/(m K)]
else
    dynVisc=XSteam('my_pT',pressure,temp_fluid); % in N*s/m2
    isobaricHeatCap=XSteam('Cp_pT',pressure,temp_fluid)*1000 ;% in J/(kg*K)
    thermalCond=XSteam('tc_pT',pressure,temp_fluid); % W/(m*K)
if isnan(dynVisc)
    dynVisc=py.CoolProp.CoolProp.PropsSI('V','T',temp_fluid+273,'P',pressure*100000,'Water');
end

end
Nu=HTC*d_h/thermalCond;
Pr=dynVisc*isobaricHeatCap/thermalCond;
Re=massflow*d_h/(dynVisc*A);
end