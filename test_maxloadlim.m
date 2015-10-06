classdef Test_maxloadlim < matlab.unittest.TestCase
    
    properties
        systems = {'case2','case9'};
        directions = struct('case2',[0 1],...
            'case9',[0 0 0 0 1 0 0 0 0;
            0 0 0 0 0 0 1 0 0;
            0 0 0 0 0 0 0 0 1;
            0 0 0 0 1 0 1 0 1;
            0 0 0 0 1 0 1 0 0;
            0 0 0 0 1 0 0 0 1;
            0 0 0 0 0 0 1 0 1]');
        % For the case 2 the theoretical result is P = E^2/(2*X)
        max_load_lims = struct('case2',5);
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
            define_constants;
            % Loading the case
            mpc = loadcase('case9');
            dir_all = testCase.directions.('case9');
            dir = dir_all(:,idx_dir);
            dir = dir/norm(dir);
            results_mp = maxloadlim(mpc,dir,0);
            mll_mp = -results_mp.f;
            % Remember to set chooseStartPoint to 0 in ch_runCPF
            idx_nonzero_loads = mpc.bus(:,PD) > 0;
            dirCPF = dir(idx_nonzero_loads);
            results_cpf = ch_runCPF('case9static','loads568',0,dirCPF);
            mll_cpf = results_cpf.lambda;
            testCase.verifyEqual(mll_mp,mll_cpf,'RelTol',1e-2);
        end
        
        function testAgainstTheoretical(testCase)
            define_constants;
            % Loading the case
            mpc = loadcase('case2');
            dir = testCase.directions.('case2');
            dir = dir/norm(dir);
            res_maxloadlim = maxloadlim(mpc,dir,0);
            % Get nonzero loads
            idx_nonzero_loads = res_maxloadlim.bus(:,PD) > 0;
            max_loads = res_maxloadlim.bus(idx_nonzero_loads,PD)/res_maxloadlim.baseMVA;
            max_loads_theo = testCase.max_load_lims.('case2');
            testCase.verifyEqual(max_loads,max_loads_theo,'RelTol',1e-2);
        end
    end
end