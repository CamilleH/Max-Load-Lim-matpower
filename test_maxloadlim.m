function tests = test_maxloadlim
tests = functiontests(localfunctions);
end

function setupOnce(testcase)
warning off MATLAB:singularMatrix
warning off MATLAB:nearlySingularMatrix
end

function teardownOnce(testcase)
warning on MATLAB:singularMatrix
warning on MATLAB:nearlySingularMatrix
end

function testFunctionOne(testCase)
% Loading the case
mpc = loadcase('case9');
dir = [1;1;1];
dir = dir/norm(dir);
results = maxloadlim(mpc,dir);
results2 = ch_runCPF('case9static','loads568',0,dir);
assert(abs(abs(results.x(end))-results2.lambda)<0.05);
end

function testFunctionTwo(testCase)
% Loading the case
mpc = loadcase('case9');
dir = [1;0;1];
dir = dir/norm(dir);
results = maxloadlim(mpc,dir);
results2 = ch_runCPF('case9static','loads568',0,dir);
assert(abs(abs(results.x(end))-results2.lambda)<0.05);
end

function testFunctionThree(testCase)
% Loading the case
mpc = loadcase('case9');
dir = [1;0;0];
dir = dir/norm(dir);
results = maxloadlim(mpc,dir);
results2 = ch_runCPF('case9static','loads568',0,dir);
assert(abs(abs(results.x(end))-results2.lambda)<0.05);
end


% % Creating different directions
% dirs = eye(3);
% dir_others = [1 1 1;
%     1 1 0;
%     1 0 1;
%     0 1 1]';
% dirs = [dirs dir_others];
% % Normalizing the search directions
% norms = sqrt(sum(abs(dirs').^2,2));
% dirs = bsxfun(@rdivide,dirs,norms');
% 
% %% Testing directions
% for i=1:length(dirs)
%     diri = dirs(:,i);
%     results = maxloadlim(mpc,diri);
%     results2 = ch_runCPF('case9static','loads568',0,diri);
%     assert(abs(abs(results.x(end))-results2.lambda)<0.05);
% end
% end