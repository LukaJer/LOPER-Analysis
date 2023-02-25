 function HTC=HTC_sim_1P(Re,Pr,pos,thermCond)
 %% Calculation of the 1-phase HTC for laminar flow, const. heat flux on inside wall, annular ring [W/(m2 K)]
d_o=26.4/1000;
d_i=10/1000;
d_h=d_o-d_i;
ratio=d_i/d_o;

Nu_FD=1.217*ratio^(-0.781)+0.035*ratio^(-1.091)+4.133; % Fully Developed Flow

B=0.038*ratio^(-0.868)+0.552;
C=0.007*ratio^(-0.452)-0.426;
D=-124.8*ratio^(0.023)+62.41;
z=pos/(d_h*Re*Pr);
Nu_D=Nu_FD+B*z^C*exp(D*z); %Developing Flow

HTC=Nu_D*thermCond/d_h;

end