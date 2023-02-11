R=[1e9 10e9 100e9 1e12 10e12 ];
C=29.57e-12;
t=0:0.1:60;
V_V0=zeros(length(t),length(R));
for i=1:length(R)
 V_V0(:,i)=exp(-t./(R(i)*C));
end
plot(t,V_V0)
legend('1GOhm','10GOhm','10GOhm','1TOhm','10TOhm');
t_dis=@(R,U_U0)  R*C*log(1/U_U0);