classdef Test_maxloadlim < matlab.unittest.TestCase
    
    properties
        systems = {'case2','case9'};
        directions = struct('case2',1,...
            'case9',[1 0 0;
            0 1 0;
            0 0 1;
            1 1 1;
            1 1 0;
            1 0 1;
            0 1 1]');
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
            dir_all = testCase.directions.('case9');
            dir = dir_all(:,idx_dir);
            dir = dir/norm(dir);
            results_mp = maxloadlim(mpc,dir,0);
            mll_mp = -results_mp.f;
            % Remember to set chooseStartPoint to 0 in ch_runCPF
            results_cpf = ch_runCPF('case9static','loads568',0,dir);
            mll_cpf = results_cpf.lambda;
            testCase.verifyEqual(mll_mp,mll_cpf,'RelTol',1e-2);
        end
        
        function testAgainstYalmip(testCase,idx_dir)
            % Loading the case
            mpc = loadcase('case2');
            dir_all = testCase.directions.('case2');
            dir = dir_all(:,idx_dir);
            dir = dir/norm(dir);
            idxVarPQ = 1;%[5 7 9];
            results_mp = maxloadlim(mpc,dir,0);
            mll_mp = -results_mp.f;
            results_yal = findmaxll('case2',idxVarPQ,dir);
            mll_yal = results_yal.lambda;
            testCase.verifyEqual(mll_mp,mll_yal,'RelTol',1e-2);
        end
    end
end