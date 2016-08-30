 % Usually "template" is the name of the file you're testing
 % You must hand in testCase object to each
 % Test results using verify (test fail or pass),assert or error (test pass or incomplete: won't run rest of script), assume (??) or fatal (kill test suite!)
 % setup and teardown functions will run before and after all the test functions
 % try to keep everything mathcing - names and structure!
 
 % You MUST add this filename "template" to do_testing file to run in the suite.
 
 
function tests = test_check_basic_struct %main fn so name should match filename
	tests = functiontests(localfunctions);
end
% Note testing started after the function was written. Basic functionality still not tested yet.
 
%% Test functions
% 1 Failure for bad get_opts.speed_sector input
% 2 Failure for bad get_opts.speed_sector input
% 3 Failure for bad get_opts.speed_sector input
% 4 Failure for bad get_opts.speed_sector input
% 5 Failure for bad get_opts.speed_sector input
% 6 Pass good get_opts.speed_sector input
% 7 Failure for bad get_opts.speed_sector input


function test_check_basic_struct_1(testCase)
% Test 1: throw out non-cell inputs
	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = [1:6];
	

	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputType');
	

end



function test_check_basic_struct_2(testCase)
%Test 2: throw out get_opts.speed_sectors inputs of length not two

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {3,3,4};
	
	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputSize');

end


function test_check_basic_struct_3(testCase)
%throw out get_opts.speed_sectors inputs of two vectors in cell

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {[3:4],[1:6]};
	
	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputSizeOrValue');

end


function test_check_basic_struct_4(testCase)
%throw out get_opts.speed_sectors inputs with much quantiles asked for than exist

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {3,[1:6]};
	
	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputSizeOrValue');

end


function test_check_basic_struct_5(testCase)
%throw out get_opts.speed_sectors with quantiles asked for that dont exist

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {3,[4:6]};
	
	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputSizeOrValue');

end


function test_check_basic_struct_6(testCase)
%check good one passes

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {6,[1:6]};
	
	check_basic_struct(gopts,'get_opts');
	

end


function test_check_basic_struct_7(testCase)
%throw out get_opts.speed_sectors with two inouts but not both double

	gopts = make_basic_struct('get_opts');
	gopts.speed_sectors = {'blah',[1:6]};
	
	
	verifyError(testCase,@()check_basic_struct(gopts,'get_opts'),'check_basic_struct:BadInputType');

end

% %% Optional file fixtures  
% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end