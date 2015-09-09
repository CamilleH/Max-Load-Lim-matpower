classdef Test_maxloadlim < matlab.unittest.TestCase
    
    properties
        directions = [1 0 0;
            0 1 0;
            0 0 1;
            1 1 1;
            1 1 0;
            1 0 1;
            0 1 1]';
    end
    properties(TestParameter)
        idx_dir = num2cell(1:7);
    end
    methods(TestClassSetup)
        function setuptests(testcase)
            % This is to turn off the warnings in the CPF when we get close
            % to the nose
            warning off MATLAB:singularMatrix
            warning off MATLAB:nearlySingularMatrix
            clc;
        end
    end
    
    methods(TestClassTeardown)
        function teardownOnce(testcase)
            warning on MATLAB:singularMatrix
            warning on MATLAB:nearlySingularMatrix
        end
    end
    
    methods(Test)        
        function testAgainstCPF(testCase,idx_dir)
            % Loading the case
            mpc = loadcase('case9');
            dir = testCase.directions(:,idx_dir);
            dir = dir/norm(dir);
            results_mp = maxloadlim(mpc,dir,0);
            mll_mp = -results_mp.f;
            results_cpf = ch_runCPF('case9static','loads568',0,dir);
            mll_cpf = results_cpf.lambda;
            testCase.verifyEqual(mll_mp,mll_cpf,'RelTol',1e-2);
        end
        
        function testAgainstYalmip(testCase,idx_dir)
            % Loading the case
            mpc = loadcase('case9');
            dir = testCase.directions(:,idx_dir);
            dir = dir/norm(dir);
            results_mp = maxloadlim(mpc,dir,0);
            mll_mp = -results_mp.f;
            results_yal = findmaxll('case9static','loads568',dir);
            mll_yal = results_yal.lambda;
            testCase.verifyEqual(mll_mp,mll_yal,'RelTol',1e-2);
        end
    end
end