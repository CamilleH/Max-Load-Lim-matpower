function results = postproc_maxloadlim(results,dir_mll)
% POSTPROC_MAXLOADLIM Performs some post processing on the results returned
% by the ACOPF run in MATPOWER.
%   RESULTS = POSTPROC_MAXLOADLIM(RESULTS,DIR_MLL) transforms the dispatchable
%   loads back to normal loads and parse the results in the struct RESULTS
%   to provide contextual information on the maximum loadability point
%   found in the direction of load increase defined by DIR_MLL. It returns
%   the updated struct RESULTS.

define_constants;

% Transforming the dispatchable gen back to loads
idx_gen_load_disp = results.gen(:,PG) < 0;
idx_bus_load_disp = results.gen(idx_gen_load_disp,GEN_BUS);
results.bus(idx_bus_load_disp ,[PD QD]) = -results.gen(idx_gen_load_disp,[PG QG]);
results.gen(idx_gen_load_disp,:) = [];
results.gencost(idx_gen_load_disp,:) = [];

% Create a new field for the stability margin
results.stab_marg = results.var.val.alpha;

% Remove the cost for the printpf function to consider the results as load
% flow results.
results.f = [];
% Direction defined over all buses (not only over nonzero loads)
results.dir_mll = dir_mll;

% Determining the type of bifurcation (SNB or SLL)
% SLL is characterized by having both reactive power limit and voltage
% limit binding at one generator
shadow_price_Qg = results.var.mu.u.Qg;
% Removing the shadow prices corresponding to dispatchable loads
shadow_price_Qg(idx_gen_load_disp) = []; 
shadow_price_Vm = results.var.mu.u.Vm;
% Map the shadow price of bus voltage magnitude to generators
shadow_price_Vg = shadow_price_Vm(results.gen(:,GEN_BUS));

idx_bus_sll = shadow_price_Qg & shadow_price_Vg;
if sum(idx_bus_sll) > 0
    results.bif.short_name = 'LIB';
    results.bif.full_name = 'limit-induced bifurcation';
    results.bif.gen_sll = find(results.gen(:,GEN_BUS) == results.bus(idx_bus_sll,BUS_I));
else
    results.bif.short_name = 'SNB';
    results.bif.full_name = 'saddle-node bifurcation';
end
end