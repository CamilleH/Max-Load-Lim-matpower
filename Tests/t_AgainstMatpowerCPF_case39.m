function t_AgainstMatpowerCPF_case39(quiet)
% This function tests the maxloadlim extension to the OPF in MATPOWER
% against MATPOWER implementation of a CPF
if nargin < 1
    quiet = 0;
end
define_constants;
% Loading the case
mpc = loadcase('case39');
% Defining several load increase directions to be tested
dir_all = [eye(39);ones(1,39)];
idx_nonzero_loads = mpc.bus(:,PD) > 0;
% Number of load increase directions
nb_dir = size(dir_all,1);
% Message header
t0 = 'case39: ';

num_tests = nb_dir; % we don't consider the direction with all zeros
t_begin(num_tests, quiet);
for i = 1:nb_dir
    dir = dir_all(i,:)';
    dir(~idx_nonzero_loads)=0;
    if sum(dir) == 0 || i == 31
        % The code does not currently support load increase at
        % nonzero loads.
        % The MATPOWER CPF takes long time for increase at bus 31
        % which is the slack bus.
        t = sprintf('%s All load zeros or increase at slack bus => SKIPPED',t0);
        t_is(1,1,0,t);
    else
        % Preparing the target case for Matpower CPF
        mpc_target = mpc;
        nonzero_loads = mpc_target.bus(:,PD) ~= 0;
        Q_P = mpc_target.bus(nonzero_loads,QD)./mpc_target.bus(nonzero_loads,PD);
        mpc_target.bus(:,PD) = mpc_target.bus(:,PD)+2*dir*mpc_target.baseMVA;
        mpc_target.bus(nonzero_loads,QD) = Q_P.*mpc_target.bus(nonzero_loads,PD);
        % Run the CPF with matpower
        [results,~] = runcpf(mpc,mpc_target,mpoption('out.all',0,'verbose',0));
        % Extract the maximum loads
        max_loads_cpf = results.bus(:,PD);
        % Solve the maximum loadability limit without considering
        % reactive power limits
        results_mll = maxloadlim(mpc,dir,'use_qlim',0,'verbose',0);
        % Extract the maximum loads
        max_loads_mll = results_mll.bus(:,PD);
        % We compare with a precision of 1MW
        t = sprintf('%sdirection: %s',t0,mat2str(dir));
        t_is(max_loads_cpf,max_loads_mll,0,t);
    end
end
t_end;
end