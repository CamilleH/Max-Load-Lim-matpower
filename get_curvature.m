function dN = get_curvature(results_mll,normal)
define_constants;

%% First step: get Phi_lambda where x=Phi(lambda)
% get dS_dlambda
[dP_dload,dQ_dload] = get_dS_dlambda(results_mll);
Vm = results_mll.bus(:,VM);
Va = results_mll.bus(:,VA);
V = Vm .* exp(1j * Va);
[Ybus,~] = makeYbus(results_mll.baseMVA, results_mll.bus, results_mll.branch);
% The left eigenvector corresponding to the zero eigenvalue is the 
% Lagrangian multipliers
lamP = results_mll.bus(:,LAM_P);
lamQ = results_mll.bus(:,LAM_Q);
% Getting the right eigenvector. Note the Jac matrix is the reduced Jac
% containing only the relevant PV,PQ equations and variables
Jac = makeJac(results_mll);
[v,eigval] = eigs(Jac,1,'sm'); 
% Get the second derivatives times the left eigenvector (Lagrange
% multipliers)
[wGpaa,wGpav,wGpva,wGpvv] = d2Sbus_dV2(Ybus, V, lamP);
[wGqaa,wGqav,wGqva,wGqvv] = d2Sbus_dV2(Ybus, V, lamQ);
% Add the active and reactive power parts of the second derivatives
[~, pv, pq] = bustypes(results_mll.bus, results_mll.gen);
pvpq = [pv;pq];
wd2G = real([wGpaa(pvpq,pvpq) wGpav(pvpq,pq); wGpva(pq,pvpq) wGpvv(pq,pq)]) +...
    imag([wGqaa(pvpq,pvpq) wGqav(pvpq,pq); wGqva(pq,pvpq) wGqvv(pq,pq)]);
% Normalise
wd2G = wd2G/norm(normal);
% Multiply by the right eigenvector
wd2Gv = v'*wd2G;
% Forming the system of equations
A = [Jac;wd2Gv];
B = [dP_dload(pvpq,:);dQ_dload(pq,:);zeros(1,size(dQ_dload,2))];
Phi_lambda = -A\B;
%% Curvature tensor
dN = Phi_lambda.'*wd2G*Phi_lambda;
end