 % Usually "template" is the name of the file you're testing
 % You must hand in testCase object to each
 % Test results using verify (test fail or pass),assert or error (test pass or incomplete: won't run rest of script), assume (??) or fatal (kill test suite!)
 % setup and teardown functions will run before and after all the test functions
 % try to keep everything mathcing - names and structure!
 
 % You MUST add this filename "template" to do_testing file to run in the suite.
 
 
function tests = template %main fn so name should match filename
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 description
% 2 description


function test_template_1(testCase)
% Test 1 more detailed description

end


function test_template_2(testCase)
%Test 2 more detailed description

end




% %% Optional file fixtures  
% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end