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
if length(dir_mll) ~= n_vl
    error_msg = ['The number of dispatchable loads is not equal to the '...
        'length of the direction vector'];
    error(error_msg);
end
% Add the amount of load increase alpha with 0 <= alpha <= inf
om = add_vars(om,'alpha',1,0,0,inf);

% Add the constraint for enforcing the direction of load increase
Pl0 = -mpc.gen(idx_vl,PG)/mpc.baseMVA;
% A_dirmll = [zeros(n_vl,n_g) eye(n_vl,n_g) dir_mll];
idx_A_dirmll_i = [1:n_vl 1:n_vl]';
idx_A_dirmll_j = [n_g+(1:n_vl) (n_g+n_vl+1)*ones(1,n_vl)]';
vals_A_dirmll = [ones(n_vl,1);dir_mll];
A_dirmll = sparse(idx_A_dirmll_i,idx_A_dirmll_j,vals_A_dirmll,n_vl,n_g+n_vl+1);
om = add_constraints(om,'dir_mll',A_dirmll,-Pl0,-Pl0,{'Pg','alpha'});
% Add cost of alpha to -1 to maximize loads in the given direction
om = add_costs(om,'alpha_cost',struct('Cw',-1),{'alpha'});
end