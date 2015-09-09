function results = maxloadlim(mpc,dir_mll,printOut)
% MAXLOADLIM computes the maximum loadability limit in one direction

% Prepare the matpower case for the maximum loadability limit problem
mpc_vl = prepare_maxll(mpc,dir_mll);

% Run opf
mpopt = mpoption('verbose',0,'opf.init_from_mpc',1);
if nargin == 3 && printOut == 0
    % Turning off the printing if requested
    mpopt = mpoption(mpopt,'out.all',0);
end
results = runopf(mpc_vl,mpopt);
end