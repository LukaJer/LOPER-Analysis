close all
clear all
V_s=0:0.1:10;
C_2=0:10:1000;
C_2=C_2';
V_2=330./(C_2+330)*V_s;
contourf(C_2,V_s,V_2')
xlabel('C_2 in pF')
ylabel('V_s in V')