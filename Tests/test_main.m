addpath('../');
%% All tests
testcase = matlab.unittest.TestSuite.fromClass(?Test_maxloadlim);
res = run(testcase);

%% Specific tests only
testcase = matlab.unittest.TestSuite.fromMethod(?Test_maxloadlim,'testAgainstCPF_case9');
res = run(testcase(2));
