function results = postproc_maxloadlim(results,dir_mll)
% POSTPROC_MAXLOADLIM Performs some post processing on the results returned
% by the ACOPF run in MATPOWER.
%   RESULTS = POSTPROC_MAXLOADLIM(RESULTS) transforms the dispatchable
%   loads back to normal loads and return the updated RESULTS.

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
end