function normal = get_normal(results_mll)
% This function returns the normal vector from the solution of a MLL
% problem
define_constants;
[~, pv, pq] = bustypes(results_mll.bus, results_mll.gen);
nonzero_loads = find(results_mll.bus(:,PD)~=0);
wleft_p = results_mll.bus([pv;pq],LAM_P);
wleft_q = results_mll.bus(pq,LAM_Q);
wleft=[wleft_p;wleft_q];
% Derivative of Jacobian w.r.t parameters. The order of the equations in w
% is: P(pv),P(pq), Q(pq)
nb_bus = size(results_mll.bus, 1);
% Load
[dP_dload,dQ_dload] = get_dS_dlambda(results_mll);
dP_dload = dP_dload([pv;pq],nonzero_loads);
dQ_dload = dQ_dload(pq,nonzero_loads);
dS_load = [dP_dload;dQ_dload];
normal = wleft'*dS_load;