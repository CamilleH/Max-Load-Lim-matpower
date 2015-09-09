clear;clc;
define_constants;
mpc = loadcase('case9');
dir = [0;1;0];
dir = dir/norm(dir);
results = maxloadlim(mpc,dir);

%%
mpc = loadcase('case9');
mpc_targ = mpc;
tanphi = mpc_targ.bus([5 7 9],QD)./mpc_targ.bus([5 7 9],PD);
mpc_targ.bus([5 7 9],PD) = mpc_targ.bus([5 7 9],PD)+10*dir;
mpc_targ.bus([5 7 9],QD) = mpc_targ.bus([5 7 9],PD).*tanphi;
mpopt = mpoption('cpf.step',0.001);
runcpf(mpc,mpc_targ);