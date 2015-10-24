clc;clear;

define_constants;

dir = zeros(9,1);
dir(7) = 1;

mpc = loadcase('case9');
mpc_target = mpc;
nonzero_loads = mpc_target.bus(:,PD) ~= 0;
Q_P = mpc_target.bus(nonzero_loads,QD)./mpc_target.bus(nonzero_loads,PD);
mpc_target.bus(:,PD) = mpc_target.bus(:,PD)+2*dir*mpc_target.baseMVA;
mpc_target.bus(nonzero_loads,QD) = Q_P.*mpc_target.bus(nonzero_loads,PD);

[results_cpf,success] = runcpf(mpc,mpc_target);
results_mll = maxloadlim(mpc,dir,'use_qlim',0);

%% Run a PF from the results
mpc = loadcase('case9');
mpc.bus = results_cpf.bus;
runpf(mpc);
mpc.bus = results_mll.bus(:,1:13);
% mpc.bus(7,PD) = results_cpf.bus(7,PD);
% mpc.bus(7,QD) = results_cpf.bus(7,QD);
% mpc.bus(:,VA) = results_cpf.bus(:,VA);
% mpc.bus(:,VM) = results_cpf.bus(:,VM);
runpf(mpc);

[results_cpf.bus(:,[VA VM]) results_mll.bus(:,[VA VM])]