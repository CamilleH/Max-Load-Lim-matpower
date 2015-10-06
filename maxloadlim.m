function results = maxloadlim(mpc,dir_mll,printOut)
% MAXLOADLIM computes the maximum loadability limit in one direction. It
% uses dispatchable loads in MATPOWER
%   RESULTS = MAXLOADLIM(MPC,DIR_MLL) returns the results from the
%   optimization problem looking for the maximum loadability limit in
%   the direction of load increase DIR_MLL. DIR_MLL defines the directions
%   of load increases for all buses. For buses with zero loads, the
%   direction of load increases must be zero. RESULTS contains the results
%   from the runopf function, in which dispatchable loads have been
%   transformed to normal loads.
%   RESULTS = MAXLOADLIM(MPC,DIR_MLL,PRINTOUT) with PRINTOUT = 0 turns off
%   MATPOWER messages when solving the optimization problem.
%
%   See also PREPARE_MAXLL, RUNOPF.

define_constants;

%% Prepare the matpower case for the maximum loadability limit problem
mpc_vl = prepare_maxll(mpc,dir_mll);

%% Run opf
mpopt = mpoption('verbose',0,'opf.init_from_mpc',1);
if nargin == 3 && printOut == 0
    % Turning off the printing if requested
    mpopt = mpoption(mpopt,'out.all',0);
end
results = runopf(mpc_vl,mpopt);

%% Transforming the dispatchable gen back to loads
idx_gen_load_disp = results.gen(:,PG) < 0;
results.bus(results.gen(idx_gen_load_disp,GEN_BUS),[PD QD]) = -results.gen(idx_gen_load_disp,[PG QG]);
results.gen(idx_gen_load_disp,:) = [];
results.gencost(idx_gen_load_disp,:) = [];
end