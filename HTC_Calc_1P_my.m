 function HTC=HTC_Calc_1P_my(massflow,pressure,temp_fluid,temp_wall,pos,x)
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

    dynVisc_w=refpropm('V','P',pressure*100000,'T',temp_wall+273,'Water');
    isobaricHeatCap_w=refpropm('C','P',pressure*100000,'T',temp_wall+273,'Water');
    thermalCond_w=refpropm('L','P',pressure*100000,'T',temp_wall+273,'Water');
else
    dynVisc=XSteam('my_pT',pressure,temp_fluid); % in N*s/m2
    isobaricHeatCap=XSteam('Cp_pT',pressure,temp_fluid)*1000 ;% in J/(kg*K)
    thermalCond=XSteam('tc_pT',pressure,temp_fluid); % W/(m*K)

    dynVisc_w=XSteam('my_pT',pressure,temp_wall);
    isobaricHeatCap_w=XSteam('Cp_pT',pressure,temp_wall)*1000;
    thermalCond_w=XSteam('tc_pT',pressure,temp_wall);
    
    if isnan(dynVisc)
        dynVisc=py.CoolProp.CoolProp.PropsSI('V','P',pressure*100000,'T',temp_fluid+273,'Water');
    end

end

Pr=dynVisc*isobaricHeatCap/thermalCond;
Pr_wall=dynVisc_w*isobaricHeatCap_w/thermalCond_w;
Re=massflow*d_h/(dynVisc*A);

    if (Re<2300)
        Nu_m=x(1)*Re.^x(2).*Pr.^x(3).*pos.^x(4);

    elseif(2300<Re && Re<10000)
        Nu_1=3.66+1.2*ratio^(-0.8);
        Nu_2=1.615*(1+0.14*ratio^(-1/2))*(2300*Pr*d_h/pos)^(1/3);
        Nu_3=(2/(1+22*Pr))^(1/6)*(2300*Pr*d_h/pos)^(1/2);
        Nu_m_L=(Nu_1^3+Nu_2^3+Nu_3^3)^(1/3);

        Re_s=2300*((1+ratio^2)*log(ratio)+(1-ratio^2))/(log(ratio)*(1-ratio)^2);
        k1=1.07+900/2300-0.63/(1+10*Pr);
        press_loss=(1.8*log10(Re_s)-1.5)^(-2);
        Nu_m_T=(press_loss/8*10000*Pr)/(k1+12.7*sqrt(press_loss/8)*(Pr^(2/3)-1))*(1+(d_h/pos)^(2/3))*0.75*ratio^(-0.17);
        gamma=(Re-2300)/(10000-2300);
        Nu_m=(1-gamma)*Nu_m_L+gamma*Nu_m_T;
    elseif(10000<Re)
        Re_s=Re*((1+ratio^2)*log(ratio)+(1-ratio^2))/(log(ratio)*(1-ratio)^2);
        press_loss=(1.8*log10(Re_s)-1.5)^(-2);
        k1=1.07+900/Re-0.63/(1+10*Pr);
        Nu_m=(press_loss/8*Re*Pr)/(k1+12.7*sqrt(press_loss/8)*(Pr^(2/3)-1))*(1+(d_h/pos)^(2/3))*0.75*ratio^(-0.17);
    end

    Nu=Nu_m*(Pr/Pr_wall)^0.11;
    HTC=Nu*thermalCond/d_h;

end