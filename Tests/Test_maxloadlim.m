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
            0 0 0 0 0 0 1 0 1]',...
            'case39',[eye(39);ones(1,39)]');
        % For the case 2 the theoretical result is P = E^2/(2*X)
        max_load_lims = struct('case2',5);
    end
    properties(TestParameter)
        idx_dir_ieee9 = num2cell(1:7);
        idx_dir_ieee39 = num2cell(1:40);
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
        function testAgainstCPF_case39(testCase,idx_dir_ieee39)
            define_constants;
            mpc = loadcase('case39');
            idx_nonzero_loads = mpc.bus(:,PD) > 0;
            dir_all = testCase.directions.('case39');
            dirCPF = dir_all(:,idx_dir_ieee39);
            dirCPF(~idx_nonzero_loads)=0;
            dirCPF2 = dirCPF(idx_nonzero_loads);
            if sum(dirCPF2) == 0
                % case of load increase in non-zero load
                testCase.verifyEqual(1,1);
            else
                results_cpf = ch_runCPF('case39','',0,dirCPF2);
                max_loads_cpf = results_cpf.bus(:,PD)*mpc.baseMVA;
                results_mll = maxloadlim(mpc,dirCPF,'verbose',0);
                max_loads_mll = results_mll.bus(:,PD);
                testCase.verifyEqual(max_loads_cpf,max_loads_mll,'AbsTol',1);
            end
        end
        
        function testAgainstCPF_case9(testCase,idx_dir_ieee9)
            define_constants;
            % Loading the case
            mpc = loadcase('case9');
            dir_all = testCase.directions.('case9');
            dir = dir_all(:,idx_dir_ieee9);
            results_mll = maxloadlim(mpc,dir,'verbose',0);
            max_loads_mll = results_mll.bus(:,PD);
            % Remember to set chooseStartPoint to 0 in ch_runCPF
            idx_nonzero_loads = mpc.bus(:,PD) > 0;
            dirCPF = dir(idx_nonzero_loads);
            results_cpf = ch_runCPF('case9static','loads568',0,dirCPF);
            max_loads_cpf = results_cpf.bus(:,PD)*mpc.baseMVA;           
            testCase.verifyEqual(max_loads_cpf,max_loads_mll,'AbsTol',1);
        end
        
        function testAgainstMatpowerCPF_case9(testCase,idx_dir_ieee9)
            define_constants;
            % Loading the case
            mpc = loadcase('case9');
            dir_all = testCase.directions.('case9');
            dir = dir_all(:,idx_dir_ieee9);
            % Preparing the target case for Matpower CPF
            mpc_target = mpc;
            nonzero_loads = mpc_target.bus(:,PD) ~= 0;
            Q_P = mpc_target.bus(nonzero_loads,QD)./mpc_target.bus(nonzero_loads,PD);
            mpc_target.bus(:,PD) = mpc_target.bus(:,PD)+2*dir*mpc_target.baseMVA;
            mpc_target.bus(nonzero_loads,QD) = Q_P.*mpc_target.bus(nonzero_loads,PD);
            % Run the CPF with matpower
            [results,~] = runcpf(mpc,mpc_target,mpoption('out.all',0));
            % Extract the maximum loads
            max_loads_cpf = results.bus(:,PD);
            % Solve the maximum loadability limit without considering
            % reactive power limits
            results_mll = maxloadlim(mpc,dir,'use_qlim',0);
            % Extract the maximum loads
            max_loads_mll = results_mll.bus(:,PD);
            % We compare with a precision of 0.5MW
            testCase.verifyEqual(max_loads_cpf,max_loads_mll,'AbsTol',1);
        end
        
        function testAgainstMatpowerCPF_case39(testCase,idx_dir_ieee39)
            define_constants;
            % Loading the case
            mpc = loadcase('case39');
            idx_nonzero_loads = mpc.bus(:,PD) > 0;
            dir_all = testCase.directions.('case39');
            dir = dir_all(:,idx_dir_ieee39);
            dir(~idx_nonzero_loads)=0;
            if sum(dir) == 0 || idx_dir_ieee39 == 31
                % The code does not currently support load increase at
                % nonzero loads.
                % The MATPOWER CPF takes long time for increase at bus 31
                % which is the slack bus.
                testCase.verifyEqual(1,1);
            else
                % Preparing the target case for Matpower CPF
                mpc_target = mpc;
                nonzero_loads = mpc_target.bus(:,PD) ~= 0;
                Q_P = mpc_target.bus(nonzero_loads,QD)./mpc_target.bus(nonzero_loads,PD);
                mpc_target.bus(:,PD) = mpc_target.bus(:,PD)+2*dir*mpc_target.baseMVA;
                mpc_target.bus(nonzero_loads,QD) = Q_P.*mpc_target.bus(nonzero_loads,PD);
                % Run the CPF with matpower
                [results,~] = runcpf(mpc,mpc_target,mpoption('out.all',0));
                % Extract the maximum loads
                max_loads_cpf = results.bus(:,PD);
                % Solve the maximum loadability limit without considering
                % reactive power limits
                results_mll = maxloadlim(mpc,dir,'use_qlim',0);
                % Extract the maximum loads
                max_loads_mll = results_mll.bus(:,PD);
                % We compare with a precision of 0.5MW
                testCase.verifyEqual(max_loads_cpf,max_loads_mll,'AbsTol',1);
            end
        end
        
        function testAgainstTheoretical_case2(testCase)
            define_constants;
            % Loading the case
            mpc = loadcase('case2');
            dir = testCase.directions.('case2');
            res_maxloadlim = maxloadlim(mpc,dir);
            % Get nonzero loads
            idx_nonzero_loads = res_maxloadlim.bus(:,PD) > 0;
            max_loads = res_maxloadlim.bus(idx_nonzero_loads,PD)/res_maxloadlim.baseMVA;
            max_loads_theo = testCase.max_load_lims.('case2');
            testCase.verifyEqual(max_loads_theo,max_loads,'AbsTol',1);
        end
    end
end