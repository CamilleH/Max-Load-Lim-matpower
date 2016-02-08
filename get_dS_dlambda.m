function [dP_dload,dQ_dload] = get_dS_dlambda(mpc)
define_constants;
nb_bus = size(mpc.bus, 1);
nonzero_loads = find(mpc.bus(:,PD)~=0);
dP_dload = speye(nb_bus);
Q_P = zeros(nb_bus,1);
Q_P(nonzero_loads) = mpc.bus(nonzero_loads,QD)./mpc.bus(nonzero_loads,PD);
dQ_dload = diag(Q_P);
end