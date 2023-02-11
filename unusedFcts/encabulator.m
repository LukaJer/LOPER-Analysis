clear

Files=dir(fullfile('matFolder','*.mat'));
% a=0;
% for i=1:height(Files)
%     matObj = matfile(Files(i).name)
%     a=a+size(matObj,'Nu')
% end
% Nu=zeros(a(1),10);
% Re=zeros(a(1),10);
% Pr=zeros(a(1),10);

Nu_exp=[];
Pr_exp=[];
Re_exp=[];

Nu_exp_avg=[];
Pr_exp_avg=[];
Re_exp_avg=[];

for i=1:height(Files)
    matObj = matfile(Files(i).name);
    Nu_exp=[Nu_exp; matObj.Nu];
    Re_exp=[Re_exp; matObj.Re];
    Pr_exp=[Pr_exp; matObj.Pr];

%     Nu_exp_avg=[Nu_exp_avg; mean(matObj.Nu)];
%     Re_exp_avg=[Re_exp_avg; mean(matObj.Re)];
%     Pr_exp_avg=[Pr_exp_avg; mean(matObj.Pr)];

end

Nu_exp=movmean(Nu_exp,10);
Re_exp=movmean(Re_exp,10);
Pr_exp=movmean(Pr_exp,10);

%% x(1)=C, x(2)=n, x(3)=m, x(4)=k
%p=1:10;
p=[18 168.3 318 467.9 668.4 718.5 768.3 817.7 868.9 918.6]/1000;
f_pos=@(x) Nu_exp-(x(1)*Re_exp.^x(2).*Pr_exp.^x(3).*p.^x(4));
% f_avg_pos=@(x) Nu_exp_avg-(x(1)*Re_exp_avg.^x(2).*Pr_exp_avg.^x(3).*p.^x(4));

f=@(x) Nu_exp-(x(1)*Re_exp.^x(2).*Pr_exp.^x(3));
% f_avg=@(x) Nu_exp_avg-(x(1)*Re_exp_avg.^x(2).*Pr_exp_avg.^x(3));

%options = optimoptions(options,'options.MaxFunctionEvaluations',1000);
opts = optimoptions(@lsqnonlin,'MaxFunctionEvaluations',15000,'MaxIterations',15000);

[x_opt_all_pos, resnorm_all_pos, residual_all_pos, status_all_pos]=lsqnonlin(f_pos,[0.1, 0.1, 0.1, 0.1],[],[],opts);
% [x_opt_all_avg_pos, resnorm_all_avg_pos, residual_all_avg_pos, status_all_avg_pos]=lsqnonlin(f_avg_pos,[0.1, 0.1, 0.1, 0.1],[],[],opts);

[x_opt_all, resnorm_all, residual_all, status_all]=lsqnonlin(f,[0.1, 0.1, 0.1, 0.1],[],[],opts);
% [x_opt_all_avg, resnorm_all_avg, residual_all_avg, status_all_avg]=lsqnonlin(f_avg,[0.1, 0.1, 0.1, 0.1],[],[],opts);


%ga(f,3);
%patternsearch(f,[0.1, 0.1, 0.1]);
%fminunc(f,[1, 1, 1]);

% rng default % For reproducibility
% gs = GlobalSearch;
% f=@(x) Nu_exp-(x(1)*Re_exp.^x(2).*Pr_exp.^x(3));
% problem = createOptimProblem('fmincon','x0','objective',f,[0.1, 0.1, 0.1],options=opts);
% x = run(gs,problem)

x_opt_pos=zeros(4,10);
resnorm_pos=zeros(1,10);
residual_pos=zeros(height(Nu_exp),10);
status_pos=zeros(1,10);

x_opt=zeros(3,10);
resnorm=zeros(1,10);
residual=zeros(height(Nu_exp),10);
status=zeros(1,10);

x0=[1, 1, 1];
x0_pos=[1, 1, 1, 1];

for j=1:10
    f_pos=@(x) Nu_exp(:,j)-(x(1)*Re_exp(:,j).^x(2).*Pr_exp(:,j).^x(3).*j^x(4));
    [x_opt_pos(:,j), resnorm_pos(j), residual_pos(:,j), status_pos(j)]=lsqnonlin(f_pos,x0_pos,[],[],opts);

        f=@(x) Nu_exp(:,j)-(x(1)*Re_exp(:,j).^x(2).*Pr_exp(:,j).^x(3));
    [x_opt(:,j), resnorm(j), residual(:,j), status(j)]=lsqnonlin(f,x0,[],[],opts);

end

deviation=residual./Nu_exp;


% x_opt_avg=zeros(3,10);
% resnorm_avg=zeros(1,10);
% residual_avg=zeros(height(Nu_exp),10);
% status_avg=zeros(1,10);
% k=0;
% for i=1:height(Files)
%     for j=1:10
%         k=k+1;
%         f_avg=@(x) Nu_exp_avg(i,j)-(x(1)*Re_exp_avg(i,j).^x(2).*Pr_exp_avg(i,j).^x(3));
%         [x_opt_avg(:,k)]=fminunc(f_avg,x0);
%     end
% end
% x_opt_avg=x_opt_avg';

% Nu_1=Nu_exp(:,1);
% Re_1=Re_exp(:,1);
% Pr_1=Pr_exp(:,1);
%
% f=@(x,N) Nu_1-(x(1)*Re_1.^x(2).*Pr_1.^x(3));
%
% patternsearch(f,[0.1, 0.1, 0.1]);

% Nu_3=Nu_exp(:,3);
% Re_3=Re_exp(:,3);
% Pr_3=Pr_exp(:,3);
