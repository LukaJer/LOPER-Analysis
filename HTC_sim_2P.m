function HTC = HTC_sim_2P(temp_fluid,pressure,heat_flux,VapourFrac,position,massflow)
%% Two-Phase HTC Calculation as per VDI Wärmeatlas [W/m^2 K]

D_h=0.0164; % d_o-d_i in m
HTC_0=25580; % W/(m2*K)
C_F=0.72;
q_0=150000; % W
p_c=220.64; % bar
d_0=0.01; % m
R_a0=0.000001; % m
R_a=0.000000545;
r_cr=0.3e-6;

if ispc
    rho1=refpropm('D','P',pressure*100,'Q',0,'Water'); %[kg/m^3]
    rho2=refpropm('D','P',pressure*100,'Q',1,'Water'); %[kg/m^3]
    T_sat=refpropm('T','P',pressure*100,'Water'); %[K]
    surfTen=refpropm('I','P',pressure*100,'Water'); %[N/m]
    vaprEnth=refpropm('Y','P',pressure*100,'Water'); %[J/kg]
else
    rho1=XSteam('rhoL_p',pressure); %[kg/m^3]
    rho2=XSteam('rhoV_p',pressure); %[kg/m^3]
    T_sat=XSteam('Tsat_p',pressure)+273.15; %[K]
    surfTen=XSteam('st_p',pressure); %[N/m]
    vaprEnth=(XSteam('hV_p',pressure)-XSteam('hL_p',pressure))*1000; %[J/kg]
end
HTC_LO=HTC_Calc_1P_liquid(massflow,pressure,0); %[W/m^2 K]
p_r=pressure/p_c;
n=0.8-0.1*10^(0.76*p_r);

heat_flux_onb=(2*surfTen*T_sat*HTC_LO)/(r_cr*rho2*vaprEnth); %minimum heat flux for nucleate boiling

% HTC Nucleate Boiling
if heat_flux_onb<heat_flux
HTC_B=HTC_0*C_F*(heat_flux/q_0)^n*2.816*p_r^0.45+(3.4+1.7/(1-p_r^7))*p_r^3.7*(d_0/D_h)^0.4*(R_a/R_a0)^0.133; %[W/m^2 K]
else
    HTC_B=0;
end
% HTC Convective Flow Boiling
HTC_L=HTC_Calc_1P_liquid(massflow,pressure,position);
HTC_V=HTC_Calc_1P_vapour(massflow,pressure,position);

HTC_C=(1-VapourFrac)^0.01*((1-VapourFrac)^1.5+1.9*VapourFrac^0.6*(rho1/rho2)^0.35)^(-2.2)+...
    VapourFrac^0.01*(HTC_V/HTC_L*(1+8*(1-VapourFrac)^0.7*(rho1/rho2)^0.67))^-2;
HTC_C=HTC_C^(-0.5)*HTC_L; %[W/m^2 K]

HTC=(HTC_C^3+HTC_B^3)^(1/3);

end


function HTC=HTC_Calc_1P_liquid(massflow,pressure,position)
%% HTC Calc for saturated liquid [W/m^2 K]
D_h=0.0164; % d_o-d_i in m
A=4.6885e-04; % in m2

if ispc
    dynVisc=refpropm('V','P',pressure*100,'Q',0,'Water'); % in Pa s
    isobaricHeatCap=refpropm('C','P',pressure*100,'Q',0,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','P',pressure*100,'Q',0,'Water'); % [W/(m K)]
else
    dynVisc=py.CoolProp.CoolProp.PropsSI('V','P',pressure*100000,'Q',0,'Water'); % in Pa s
    isobaricHeatCap=XSteam('CpL_p',pressure)*1000; % [J/(kg K)]
    thermalCond=XSteam('tcL_p',pressure); % [W/(m K)]
end


Pr=dynVisc*isobaricHeatCap/thermalCond;
Re=massflow*D_h/(dynVisc*A);

if (Re<2300)
    Nu=0.455*Pr^(1/3)*sqrt(Re*D_h/position);

elseif(2300<Re && Re<10000)
    eta=(1.82*log10(Re)-1.64)^-2;
    Nu1=0.455*Pr^(1/3)*sqrt(Re*D_h/position);
    Nu_inf=((eta/8)*(Re-1000)*Pr)/(1+12.7*sqrt(eta/8)*(Pr^(2/3)-1));
    Nu2=Nu_inf*(1+1/3*(D_h/position)^(2/3));
    Nu=max([Nu1 Nu2]);
elseif(10000<Re)
    eta=(1.82*log10(Re)-1.64)^-2;
    Nu_inf=((eta/8)*(Re-1000)*Pr)/(1+12.7*sqrt(eta/8)*(Pr^(2/3)-1));
    Nu=Nu_inf*(1+1/3*(D_h/position)^(2/3));
end
HTC=Nu*thermalCond/D_h;


end

function HTC=HTC_Calc_1P_vapour(massflow,pressure,position)
%% HTC Calc for saturated vapour [W/m^2 K]
D_h=0.0164; % d_o-d_i in m
A=4.6885e-04; % in m2


if ispc
    dynVisc=refpropm('V','P',pressure*100,'Q',1,'Water'); % in Pa s
    isobaricHeatCap=refpropm('C','P',pressure*100,'Q',1,'Water'); % [J/(kg K)]
    thermalCond=refpropm('L','P',pressure*100,'Q',1,'Water'); % [W/(m K)]
else
    dynVisc=py.CoolProp.CoolProp.PropsSI('V','P',pressure*100000,'Q',1,'Water'); % in Pa s
    isobaricHeatCap=XSteam('CpV_p',pressure)*1000; % [J/(kg K)]
    thermalCond=XSteam('tcV_p',pressure); % [W/(m K)]

end

Pr=dynVisc*isobaricHeatCap/thermalCond;
Re=massflow*D_h/(dynVisc*A);

if (Re<2300)
    Nu=0.455*Pr^(1/3)*sqrt(Re*D_h/position);

elseif(2300<Re && Re<10000)
    eta=(1.82*log10(Re)-1.64)^-2;
    Nu1=0.455*Pr^(1/3)*sqrt(Re*D_h/position);
    Nu_inf=((eta/8)*(Re-1000)*Pr)/(1+12.7*sqrt(eta/8)*(Pr^(2/3)-1));
    Nu2=Nu_inf*(1+1/3*(D_h/position)^(2/3));
    Nu=max([Nu1 Nu2]);
elseif(10000<Re)
    eta=(1.82*log10(Re)-1.64)^-2;
    Nu_inf=((eta/8)*(Re-1000)*Pr)/(1+12.7*sqrt(eta/8)*(Pr^(2/3)-1));
    Nu=Nu_inf*(1+1/3*(D_h/position)^(2/3));
end
HTC=Nu*thermalCond/D_h;


end
