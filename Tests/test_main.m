addpath('../');
%% All tests
testcase = matlab.unittest.TestSuite.fromClass(?Test_maxloadlim);
res = run(testcase);

%% Specific tests only
testcase = matlab.unittest.TestSuite.fromMethod(?Test_maxloadlim,'testAgainstMatpowerCPF_case39');%'testAgainstCPF_case39');%'testAgainstMatpowerCPF_case39');
res = run(testcase(31));
