function Q_temp_change = Pipe_Heat(T_1,T_2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

A_pipe=0.2827; % in cm2
c_p=500; % in J/(kg*K)
rho=0.0079; % in kg/cm2
l=10; % in cm

Q_temp_change=A_pipe*c_p*rho*l*((T_2-T_1)./2);

end