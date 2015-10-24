clear;clc;
import matlab.unittest.TestSuite
suite = TestSuite.fromFile('Test_maxloadlim.m');
test_sll = suite(2);
test_sll.run
res = test_sll.run;
table(res)