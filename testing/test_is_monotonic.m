 % Usually "template" is the name of the file you're testing
 % You must hand in testCase object to each
 % Test results using verify (test fail or pass),assert or error (test pass or incomplete: won't run rest of script), assume (??) or fatal (kill test suite!)
 % setup and teardown functions will run before and after all the test functions
 % try to keep everything mathcing - names and structure!
 
 % You MUST add this filename "template" to do_testing file to run in the suite.
 
 
function tests = test_is_monotonic %main fn so name should match filename
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 Input is monotonic
% 2 Input is monotonic but not strictly so
% 3 Input is not monotonic

% No testing for size of input yet, or multiple cols


function test_is_monotonic_1(testCase)
% Test 1 more detailed description
	
	A = [0 1 2 3 4 5];
	verifyTrue(testCase,is_monotonic(A));
	

end


function test_is_monotonic_2(testCase)
%Test 2 more detailed description
	A = [0 1 2 3 3 4 5];
	verifyTrue(testCase,is_monotonic(A));
end


function test_is_monotonic_3(testCase)
%Test 3 more detailed description
	A = [0 1 2 -1 3 4 5];
	verifyTrue(testCase,~is_monotonic(A));
end



% %% Optional file fixtures  
% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end