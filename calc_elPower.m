function el_Power = calc_elPower(current,temperature,length)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
area=28.27; %in mm²
alpha_20=0.005; %in m/(R*mm²)
gamma_20=1.37; %in (1/K)
resistance=length/(gamma_20*area)*(1+alpha_20*(temperature-20));
el_Power=current.^2.*resistance;
end