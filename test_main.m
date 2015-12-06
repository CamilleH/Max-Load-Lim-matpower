testcase = matlab.unittest.TestSuite.fromMethod(?Test_maxloadlim,'testAgainstCPF_case39');
failed_cases = [9 31];
res = run(testcase(failed_cases(1)));
% res = run(testcase(24));