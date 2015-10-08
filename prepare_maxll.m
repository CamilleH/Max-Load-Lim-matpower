function mpc_vl = prepare_maxll(mpc,dir_mll)
% PREPARE_MAXSLL prepares the mpc case for computing the maximum
% loadability limit by adding the relevant constraints and variables.
%   MPC_VL = PREPARE_MAXLL(MPC,DIR_MLL) returns the matpower case MPC_VL
%   prepared from MPC by transforming all loads to dispatchable loads,
%   adding a field for the direction DIR_MLL of load increase and adapting 
%   limits for the OPF formulation.
%   

define_constants;

%% CHECKS
% Check whether the number of directions of load increases is equal to the
% number of buses
if size(mpc.bus,1) ~= length(dir_mll)
    error_msg = ['The number of directions of load increases ' ...
        'is not equal to the number of buses'];
    error(error_msg);
end

% Check whether load increases have been defined for zero loads
idx_zero_loads = mpc.bus(:,PD) == 0;
if sum(dir_mll(idx_zero_loads))>0
    error('Directions of load increases cannot be defined for zero loads.');
end

%% Preparation of the case mpc_vl
% Convert all loads to dispatchable
mpc_vl = load2disp(mpc);

% Extract the part of dir_mll corresponding to nonzero loads
dir_mll = dir_mll(mpc.bus(:, PD) > 0);

% Add a field to mpc_vl for the load increase
mpc_vl.dir_mll = dir_mll;

% Adjust the Pmin of dispatchable loads to make them negative enough so
% that the max load lim can be found
idx_vl = isload(mpc_vl.gen);
tanphi_vl = mpc_vl.gen(idx_vl,QG)./mpc_vl.gen(idx_vl,PG);
mpc_vl.gen(idx_vl,PMIN) = 100*mpc_vl.gen(idx_vl,PMIN);
% Adjust Qmin so that Qmin/Pmin is the power factor of the load
mpc_vl.gen(idx_vl,QMIN) = mpc_vl.gen(idx_vl,PMIN).*tanphi_vl;
% Make the cost zero
mpc_vl.gencost(:,COST:end) = 0;
% Make the generators not dispatchable
[ref, pv, pq] = bustypes(mpc_vl.bus, mpc_vl.gen);
idx_gen_pv = find(ismember(mpc_vl.gen(:,GEN_BUS),pv));
mpc_vl.gen(idx_gen_pv,PMIN) = mpc_vl.gen(idx_gen_pv,PG);
mpc_vl.gen(idx_gen_pv,PMAX) = mpc_vl.gen(idx_gen_pv,PG);
% Raise the flow limits so that they are not binding
mpc_vl.branch(:,RATE_A) = 9999;
% Raise the slack bus limits so that they are not binding
idx_gen_slack = mpc_vl.gen(:,GEN_BUS) == ref;
mpc_vl.gen(idx_gen_slack,[QMAX,PMAX]) = 9999;
% Change the voltage constraints of the PQ buses so that they are not 
% binding
mpc_vl.bus(pq,VMIN) = 0.01;
mpc_vl.bus(pq,VMAX) = 10;
% Lock the voltages of the slack bus
mpc_vl.bus(ref,VMAX) = mpc_vl.gen(idx_gen_slack,VG);
mpc_vl.bus(ref,VMIN) = mpc_vl.gen(idx_gen_slack,VG);
% Put Vmax = Vset and low Vmin for all pv buses
mpc_vl.bus(pv,VMAX) = mpc_vl.gen(idx_gen_pv,VG);
mpc_vl.bus(pv,VMIN) = 0.01;

% Build the constraint for enforcing the direction of load increase
mpc_vl = add_userfcn(mpc_vl, 'formulation', @userfcn_direction_mll_formulation);
end