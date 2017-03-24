function test_mll_main(verbose)
% This function defines the list of tests to be run. The tests are run
% by using T_RUN_TESTS in MATPOWER.
if nargin < 1
    verbose = 0;
end


tests = {};
tests{end+1} = 't_cpf_case9';
tests{end+1} = 't_cpf_case39';
tests{end+1} = 't_varGen_case9';
tests{end+1} = 't_varGen_case39';
t_run_tests( tests, verbose );