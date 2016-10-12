addpath('../');
% Run specific tests as well?
run_specific = 0;
%% All tests
testcase = matlab.unittest.TestSuite.fromClass(?Test_maxloadlim);
res = run(testcase);

if run_specific
    %% Specific tests only
    testcase = matlab.unittest.TestSuite.fromMethod(?Test_maxloadlim,'testVarGen_case39');%'testAgainstCPF_case39');%'testAgainstMatpowerCPF_case39');
    res_2 = run(testcase);
    %%
end

% This function defines the list of tests to be run. The tests are run
% by using T_RUN_TESTS in MATPOWER.
if nargin < 1
    verbose = 0;
end

tests = {};
tests{end+1} = 't_mll_fmincon_case9';
tests{end+1} = 't_mll_fmincon_case39';
tests{end+1} = 't_mll_fmincon_vargen_case9';
t_run_tests( tests, verbose );