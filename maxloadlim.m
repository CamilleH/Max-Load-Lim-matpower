function results = maxloadlim(mpc,dir_mll)
% MAXLOADLIM computes the maximum loadability limit in one direction

% Prepare the matpower case for the maximum loadability limit problem
mpc_vl = prepare_maxll(mpc,dir_mll);

% Run opf
mpopt = mpoption('out.all',0,'verbose',0,'opf.init_from_mpc',1);
results = runopf(mpc_vl,mpopt);
end