
function tests = test_linlinhist3
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 Dimension of output 
% 2 Total number of binned values
% 3 Case where entries are equal to bin edges
% 4 Compare to case using bin_2d_data directly to check our selection of edges works out the same


function test_linlinhist3_1(testCase)
% Test for dimension of output (number of bins)
	A = rand(500,2);
	dim1 = 2;
	dim2 = 10;
	
	n = linlinhist3(A(:,1),A(:,2),[dim1 dim2]);
	
	verifyEqual(testCase,size(n),[dim1 dim2]);
end


function test_linlinhist3_2(testCase)
%Test for number of binnned values

	A = rand(500,2);
	dim1 = 2;
	dim2 = 10;
	
	n = linlinhist3(A(:,1),A(:,2),[dim1 dim2]);
	
	verifyEqual(testCase,sum(sum(n)),length(A));
end


function test_linlinhist3_3(testCase)
% Check total size when have values at edge of bins
	
	A = rand(500,2);
	A(1,:) = [0 1];
	dim1 = 2;
	dim2 = 10;
	
	n = linlinhist3(A(:,1),A(:,2),[dim1 dim2]);
	
	verifyEqual(testCase,sum(sum(n)),length(A));
end


function test_linlinhist3_4(testCase)
	
	A = rand(500,2);
	
	dim1 = 2;
	dim2 = 10;
	
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	
	n1 = linlinhist3(A(:,1),A(:,2),[dim1 dim2]);
	n2 = bin_2d_data(A,ed1,ed2);
	
	n_diff = n1 - n2;
	
	verifyEqual(testCase,sum(sum(abs(n_diff))),0); % want absolute tolerance?
end


%% Optional file fixtures  
function setupOnce(testCase)  % do not change function name
% set a new path, for example
	rng('default');
end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end