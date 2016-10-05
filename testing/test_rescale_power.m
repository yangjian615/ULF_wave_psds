 % Usually "template" is the name of the file you're testing
 % You must hand in testCase object to each
 % Test results using verify (test fail or pass),assert or error (test pass or incomplete: won't run rest of script), assume (??) or fatal (kill test suite!)
 % setup and teardown functions will run before and after all the test functions
 % try to keep everything mathcing - names and structure!
 
 % You MUST add this filename "template" to do_testing file to run in the suite.
 
 
function tests = test_rescale_power %main fn so name should match filename
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 description
% 2 description


function test_rescale_power_1(testCase)
% Test 1: does the total power roughly match up before and after scaling?
% GILL, statio, 2000, x coord only
	check_data = testCase.TestData.check_data;
	rescaled_data = rescale_power(check_data);
	
	pow1 = trapz( check_data(1).freqs, cell2mat({check_data.xps}));
	pow2 = trapz( rescaled_data(1).freqs, cell2mat({rescaled_data.xps}));
	
	diff = abs(pow1 - pow2);
	
	% scale it by means
	diff = diff./( mean([pow1',pow2'],2)' );
	
	% check not too different
	verifyTrue(testCase,sum(diff > 2) == 0);

end


function test_rescale_power_2(testCase)
%Test 2 does total power match between domains?

	check_data = testCase.TestData.check_data;
	rescaled_data = rescale_power(check_data);
	
	times = check_data(1).times;
	N = length(check_data(1).x);
	T = etime(datevec(times(1)),datevec(times(2)));
	time_axis = linspace(0,T,N);
	
	pow1 = trapz( time_axis, cell2mat({rescaled_data.x}))/T;
	pow2 = trapz( rescaled_data(1).freqs, cell2mat({rescaled_data.xps}));
	
	diff = abs(pow1 - pow2);
	
	% scale it by means
	diff = diff./( mean([pow1',pow2'],2)' );
	
	% check not too different
	verifyTrue(testCase,sum(diff > 2) == 0);

end




% %% Optional file fixtures  
function setupOnce(testCase)  % do not change function name
% % set a new path, for example
	ddir = '/glusterfs/scenario/users/mm840338/data_tester/data/';
	temp_gopts = make_basic_struct('get_opts');
	temp_gopts.y = 2000;
	temp_gopts.m = [4:6];
	testCase.TestData.check_data = get_all_psd_data(ddir,temp_gopts);
end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end