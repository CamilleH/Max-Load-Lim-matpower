function results = maxloadlim(mpc,dir_mll,varargin)
% MAXLOADLIM computes the maximum loadability limit in one direction. It
% uses dispatchable loads in MATPOWER
%   RESULTS = MAXLOADLIM(MPC,DIR_MLL) returns the results from the
%   optimization problem looking for the maximum loadability limit in
%   the direction of load increase DIR_MLL. DIR_MLL defines the directions
%   of load increases for all buses. For buses with zero loads, the
%   direction of load increases must be zero. RESULTS contains the results
%   from the runopf function, in which dispatchable loads have been
%   transformed to normal loads.
%
%   See also PREPARE_MAXLL, RUNOPF.

define_constants;

%% Checking the options, if any
input_checker = inputParser;

default_verbose = 0;
verbose_levels = [0;1];
check_verbose = @(x)(isnumeric(x) && isscalar(x) && any(x == verbose_levels));
addParameter(input_checker,'verbose',default_verbose,check_verbose);

input_checker.KeepUnmatched = true;
parse(input_checker,varargin{:});

options = input_checker.Results;

%% Prepare the matpower case for the maximum loadability limit problem
mpc_vl = prepare_maxloadlim(mpc,dir_mll,varargin{:});

%% Run opf
% Turning off the printing and initializing from the base case
mpopt = mpoption('verbose',1,'opf.init_from_mpc',1);
mpopt = mpoption(mpopt,'out.all',0);
% Decreasing the threshold for the relative complementarity constraints
mpopt = mpoption(mpopt,'mips.comptol',1e-8);
% Execute opf
results = runopf(mpc_vl,mpopt);

%% Post-processing
results = postproc_maxloadlim(results,dir_mll);

%% Printing
if options.verbose
    print_maxloadlim(mpc,results);
end
end