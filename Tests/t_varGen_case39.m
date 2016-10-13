function t_varGen_case39(quiet)
% This function tests the implementation of the variable generators in the
% IEEE 39 bus system
if nargin < 1
    quiet = 0;
end
define_constants;
% Loading the case
mpc = loadcase('case39');

% Defining several load increase directions to be tested
dir_all = [eye(39);ones(1,39)];
dir_var_gen_all = [zeros(9,1) eye(9);0 ones(1,9)];
dir_var_gen_all(:,[1 2]) = dir_var_gen_all(:,[2 1]); % Put the slack gen at the right position
idx_nonzero_loads = mpc.bus(:,PD) > 0;
% Number of load increase directions
nb_dir_load = size(dir_all,1);
nb_dir_gen = size(dir_var_gen_all,1);
% Message header
t0 = 'case39: ';

num_tests = nb_dir_load*nb_dir_gen; % we don't consider the direction with all zeros
t_begin(num_tests, quiet);
for i = 1:nb_dir_load
    dir_load = dir_all(i,:)';
    dir_load(~idx_nonzero_loads)=0;
    for j = 1:nb_dir_gen
        if sum(dir_load) == 0 || dir_load(31) ~= 0
            % The code does not currently support load increase at
            % nonzero loads or at the slack bus
            t = sprintf('%s All load zeros => SKIPPED',t0);
            t_is(1,1,0,t);
        else
            dir_var_gen = dir_var_gen_all(j,:)';
            idx_var_gen = find(dir_var_gen);
            dir_var_gen = dir_var_gen(idx_var_gen);
            % Normalizing with respect to both loads and gens
            gen_load_dir = [dir_load;dir_var_gen];
            dir_load = dir_load/norm(gen_load_dir);
            dir_var_gen = dir_var_gen/norm(gen_load_dir);
            % Find MLL in the direction of load and gen increase
            results_with_gens = maxloadlim(mpc,dir_load,'verbose',0,'idx_var_gen',idx_var_gen,'dir_var_gen',dir_var_gen);
            % Set gens to their values in previous results and re-run in
            % load space only
            mpc2 = mpc;
            mpc2.gen(:,PG) = results_with_gens.gen(:,PG);
            dir_load2 = dir_load/norm(dir_load);
            % Find MLL in the direction of load and gen increase
            results_without_gens = maxloadlim(mpc2,dir_load2,'verbose',0);
            % Compare the maximum loads
            mll_with_gen = results_with_gens.bus(:,PD);
            mll_without_gen = results_without_gens.bus(:,PD);
            % We compare with a precision of 1MW
            t = sprintf('%sLOAD: %s   GEN: %s',t0,mat2str(dir_load),mat2str(dir_var_gen));
            ok = t_is(mll_with_gen,mll_without_gen,0,t);
        end
    end
end
t_end;