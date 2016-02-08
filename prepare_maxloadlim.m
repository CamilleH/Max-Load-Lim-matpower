function mpc_vl = prepare_maxloadlim(mpc,dir_mll,varargin)
% PREPARE_MAXSLL prepares the mpc case for computing the maximum
% loadability limit by adding the relevant constraints and variables.
%   MPC_VL = PREPARE_MAXLL(MPC,DIR_MLL) returns the matpower case MPC_VL
%   prepared from MPC by transforming all loads to dispatchable loads,
%   adding a field for the direction DIR_MLL of load increase and adapting 
%   limits for the OPF formulation.
%   MPC_VL = PREPARE_MAXLL(MPC,DIR_MLL,Name,Value) does the same with additional
%   options specified in pairs Name,Value. The two supported options are as 
%   follows:
%     * 'use_qlim': 1 (Default) or 0. Enforces or not the reactive power
%     limits of the generators.
%     * 'Vlims_bus_nb': [] (Default) or array of integers. By default, the
%     bus voltage limits are not enforced. This option allows for defining
%     a set of buses at which the voltage limits are enforced.

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

%% Checking the options, if any
input_checker = inputParser;

% Q-lims
default_qlim = 1;
check_qlim = @(x)(isnumeric(x) && isscalar(x));
addParameter(input_checker,'use_qlim',default_qlim,check_qlim);

% Enfore V-lims
default_vlim = [];
check_vlim = @(x)(isnumeric(x) && all(floor(x) == ceil(x))); % expects array of integer values (bus numbers)
addParameter(input_checker,'Vlims_bus_nb',default_vlim,check_vlim);

% Parse
input_checker.KeepUnmatched = true;
parse(input_checker,varargin{:});
options = input_checker.Results;

%% Preparation of the case mpc_vl
% Convert all loads to dispatchable
mpc_vl = load2disp(mpc);
n_gen = size(mpc.gen,1);

% Extract the part of dir_mll corresponding to nonzero loads
dir_mll = dir_mll(mpc.bus(:, PD) > 0);

% Normalize the direction of load increase
dir_mll = dir_mll/norm(dir_mll);

% Add a field to mpc_vl for the load increase
mpc_vl.dir_mll = dir_mll;

% Adjust the Pmin of dispatchable loads to make them negative enough so
% that the max load lim can be found
idx_vl = isload(mpc_vl.gen);
mpc_vl.gen(idx_vl,PMIN) = 300*mpc_vl.gen(idx_vl,PMIN);
% Adjust Qmin so that Qmin/Pmin is the power factor of the load, if
% inductive, and change Qmax if the load is capacitive
idx_vl_inductive = idx_vl & mpc_vl.gen(:,QMAX) == 0;
idx_vl_capacitive = idx_vl & mpc_vl.gen(:,QMIN) == 0;
tanphi_vl_ind = mpc_vl.gen(idx_vl_inductive,QG)./mpc_vl.gen(idx_vl_inductive,PG);
tanphi_vl_cap = mpc_vl.gen(idx_vl_capacitive,QG)./mpc_vl.gen(idx_vl_capacitive,PG);
mpc_vl.gen(idx_vl_inductive,QMIN) = mpc_vl.gen(idx_vl_inductive,PMIN).*tanphi_vl_ind;
mpc_vl.gen(idx_vl_capacitive,QMAX) = mpc_vl.gen(idx_vl_capacitive,PMIN).*tanphi_vl_cap;
% Make the cost zero
mpc_vl.gencost(:,COST:end) = 0;
% Make the generators not dispatchable
[ref, pv, pq] = bustypes(mpc_vl.bus, mpc_vl.gen);
% Note, we look only for the real PV buses, i.e. we do not consider the
% dispatchable loads in this search. Hence the search over 1:n_gen
idx_gen_pv = find(ismember(mpc_vl.gen(1:n_gen,GEN_BUS),pv));
mpc_vl.gen(idx_gen_pv,PMIN) = mpc_vl.gen(idx_gen_pv,PG);
mpc_vl.gen(idx_gen_pv,PMAX) = mpc_vl.gen(idx_gen_pv,PG);
% Raise the flow limits so that they are not binding
mpc_vl.branch(:,RATE_A) = 9999;%1e5;
% Raise the slack bus limits so that they are not binding
idx_gen_slack = find(mpc_vl.gen(1:n_gen,GEN_BUS) == ref);
mpc_vl.gen(idx_gen_slack,[QMAX,PMAX]) = 9999;
% Change the voltage constraints of the PQ buses so that they are not 
% binding
mpc_vl.bus(pq,VMIN) = 0.01;
mpc_vl.bus(pq,VMAX) = 10;
% Lock the voltages of the slack bus
mpc_vl.bus(ref,VMAX) = mpc_vl.gen(idx_gen_slack(1),VG);
mpc_vl.bus(ref,VMIN) = mpc_vl.gen(idx_gen_slack(1),VG);
% Put Vmax = Vset and low Vmin for all pv buses
for bb = 1:length(pv)
    idx_gen_at_bb = find(mpc_vl.gen(1:n_gen,GEN_BUS),pv(bb));
    mpc_vl.bus(pv,VMAX) = mpc_vl.gen(idx_gen_at_bb(1),VG);
    mpc_vl.bus(pv,VMIN) = 0.01;
end
% If we do not consider Qlim, increase Qmax and decrease Qmin 
% of all generators to arbitrarily large values 
if ~options.use_qlim
    mpc_vl.gen(idx_gen_pv,QMAX) = 9999;
    mpc_vl.gen(idx_gen_pv,QMIN) = -9999;
    for bb = 1:length(pv)
        idx_gen_at_bb = find(mpc_vl.gen(1:n_gen,GEN_BUS),pv(bb));
        mpc_vl.bus(pv,VMAX) = mpc_vl.gen(idx_gen_at_bb(1),VG);
        mpc_vl.bus(pv,VMIN) = mpc_vl.gen(idx_gen_at_bb(1),VG);
    end
end
if ~isempty(options.Vlims_bus_nb)
    idx_gen_vlim = find(ismember(mpc_vl.gen(:,GEN_BUS),options.Vlims_bus_nb));
    mpc_vl.bus(options.Vlims_bus_nb,VMAX) = mpc_vl.gen(idx_gen_vlim,VG);
    mpc_vl.bus(options.Vlims_bus_nb,VMIN) = mpc_vl.gen(idx_gen_vlim,VG);
end

% Build the constraint for enforcing the direction of load increase
mpc_vl = add_userfcn(mpc_vl, 'formulation', @userfcn_direction_mll_formulation);
end