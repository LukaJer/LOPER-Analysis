 function HTC=HTC_Calc_1P_my(massflow,pressure,temp_fluid,pos,x)
d_o=26.4/1000;
d_i=10/1000;
d_h=d_o-d_i;
ratio=d_i/d_o; % as per VDI
%ratio=d_o/d_i % as per other stuff
A=((d_o/2)^2-(d_i/2)^2)*pi;


if ispc
    dynVisc=refpropm('V','P',pressure*100000,'T',temp_fluid+273,'Water'); % [Pa*s]
    isobaricHeatCap=refpropm('C','P',pressure*100000,'T',temp_fluid+273,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','P',pressure*100000,'T',temp_fluid+273,'Water'); %  [W/(m K)]
else
    dynVisc=XSteam('my_pT',pressure,temp_fluid); % in N*s/m2
    isobaricHeatCap=XSteam('Cp_pT',pressure,temp_fluid)*1000 ;% in J/(kg*K)
    thermalCond=XSteam('tc_pT',pressure,temp_fluid); % W/(m*K)
    
    if isnan(dynVisc)
        dynVisc=py.CoolProp.CoolProp.PropsSI('V','P',pressure*100000,'T',temp_fluid+273,'Water');
    end

end

Pr=dynVisc*isobaricHeatCap/thermalCond;

Re=massflow*d_h/(dynVisc*A);


        Nu_m=x(1)*Re.^x(2).*Pr.^x(3).*pos.^x(4);


    Nu=Nu_m*(Pr/Pr_wall)^0.11;
    HTC=Nu*thermalCond/d_h;

end