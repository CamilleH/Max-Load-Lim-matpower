function results = maxloadlim(mpc,dir_mll,printOut)
% MAXLOADLIM computes the maximum loadability limit in one direction

define_constants;
% Prepare the matpower case for the maximum loadability limit problem
mpc_vl = prepare_maxll(mpc,dir_mll);

% Run opf
mpopt = mpoption('verbose',0,'opf.init_from_mpc',1);
if nargin == 3 && printOut == 0
    % Turning off the printing if requested
    mpopt = mpoption(mpopt,'out.all',0);
end
results = runopf(mpc_vl,mpopt);

% Transforming the dispatchable gen back to loads
idx_gen_load_disp = results.gen(:,PG) < 0;
results.bus(results.gen(idx_gen_load_disp,GEN_BUS),[PD QD]) = -results.gen(idx_gen_load_disp,[PG QG]);
results.gen(idx_gen_load_disp,:) = [];
results.gencost(idx_gen_load_disp,:) = [];
end