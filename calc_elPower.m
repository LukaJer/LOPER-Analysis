function el_Power = calc_elPower(current,temperature,length)
%% calculates the electrical Power of a section
r_i=4; % in mm
r_o=5; % in mm
area=pi*(r_o^2-r_i^2); % in mm²
alpha_20=0.005; %in m/(R*mm²)
gamma_20=1.37; %in (1/K)
resistance=length/(gamma_20*area)*(1+alpha_20*(temperature-20));
el_Power=current.^2.*resistance;
end