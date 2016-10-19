 % Usually "template" is the name of the file you're testing
 % You must hand in testCase object to each
 % Test results using verify (test fail or pass),assert or error (test pass or incomplete: won't run rest of script), assume (??) or fatal (kill test suite!)
 % setup and teardown functions will run before and after all the test functions
 % try to keep everything mathcing - names and structure!
 
 % You MUST add this filename "template" to do_testing file to run in the suite.
 
 
function tests = test_sort_by_speed_sectors %main fn so name should match filename
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 UNlucky data means poor sorting
% 2 Quantile output
% 3 Sorted quantile bin output


function test_sort_by_speed_sectors_1(testCase)
% Check for warning when input results in poor quantile sorting

	to_sort = [3 3 3 4 4 4 5 5 5];
	num_quants = 3;

	verifyWarning(testCase,@()sort_by_speed_sectors(to_sort,num_quants),'sort_by_speed_sectors:PoorQuantileSorting');

end


function test_sort_by_speed_sectors_2(testCase)
%Check works for larger amoutns of data with right output of quantiles

	rng('default');
	to_sort = rand(100,1)*5;
	num_quants= 3;

	[quants,which_quants]= sort_by_speed_sectors(to_sort,num_quants);

	verifyEqual(testCase,length(quants),num_quants);

end


function test_sort_by_speed_sectors_3(testCase)
%Check works for larger amoutns of data with right number of sorted quantiles


	to_sort = rand(100,1)*5;
	num_quants= 3;

	[quants,which_quants]= sort_by_speed_sectors(to_sort,num_quants);

	verifyEqual(testCase,length(which_quants),length(to_sort));
	verifyEqual(testCase,length(unique(which_quants)),num_quants+1);

end




% %% Optional file fixtures  
% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end


