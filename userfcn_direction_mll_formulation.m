function om = userfcn_direction_mll_formulation(om,args)
% USERFCN_DIRECTION_MLL_FORMULATION adds one variable and as many
% constraints as dispatchable loads to enforce the load increase direction

define_constants;
mpc = get_mpc(om);
dir_mll = mpc.dir_mll;

% identify dispatchable loads
idx_vl = isload(mpc.gen);
n_vl = sum(idx_vl);
n_g = size(mpc.gen,1)-n_vl;
nbus = size(mpc.bus,1);
if length(dir_mll) ~= n_vl
    error_msg = ['The number of dispatchable loads is not equal to the '...
        'length of the direction vector'];
    error(error_msg);
end
% Add the amount of load increase alpha with 0 <= alpha <= inf
om = add_vars(om,'alpha',1,0,0,inf);

%% Load increase
% Add the constraint for enforcing the direction of load increase
Pl0 = -mpc.gen(idx_vl,PG)/mpc.baseMVA;
% finding the internal indices of the dispatchable loads
int_idx_disp_loads = find(idx_vl); 
idx_A_dirmll_i = [1:n_vl 1:n_vl]';
idx_A_dirmll_j = [int_idx_disp_loads' (n_g+n_vl+1)*ones(1,n_vl)]';
vals_A_dirmll = [ones(n_vl,1);dir_mll];
A_dirmll = sparse(idx_A_dirmll_i,idx_A_dirmll_j,vals_A_dirmll,n_vl,n_g+n_vl+1);
om = add_constraints(om,'dir_mll',A_dirmll,-Pl0,-Pl0,{'Pg','alpha'});
% Add cost of alpha to -1 to maximize loads in the given direction
om = add_costs(om,'alpha_cost',struct('Cw',-1),{'alpha'});

%% Generator changes
% Add the constraint for enforcing the direction of generation change
idx_var_gen = find(mpc.dir_var_gen_all);
if ~isempty(idx_var_gen)
    Pg0 = mpc.gen(idx_var_gen,PG)/mpc.baseMVA;
    nb_var_gen = length(idx_var_gen);
    idx_A_var_gen_i = [1:nb_var_gen 1:nb_var_gen]'; % Constraint number
    idx_A_var_gen_j = [idx_var_gen;(n_g+n_vl+1)*ones(nb_var_gen,1)]; % Generator number and alpha column (column in constraint matrix)
    vals_A_var_gen = [ones(nb_var_gen,1);-nonzeros(mpc.dir_var_gen_all)];
    A_var_gen = sparse(idx_A_var_gen_i,idx_A_var_gen_j,vals_A_var_gen,nb_var_gen,n_g+n_vl+1);
    om = add_constraints(om,'dir_var_gen',A_var_gen,...
        Pg0,Pg0,{'Pg','alpha'});
end

%% Voltage maximization
% Finally, we add a cost to maximize voltages so that they are as close as 
% possible from their upper bounds
om = add_costs(om,'voltage_cost',struct('Cw',-1e-2*ones(nbus,1)),{'Vm'});
end