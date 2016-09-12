 
function tests = testbin_2d_data
	tests = functiontests(localfunctions);
end
 
%% Test functions
% 1 Dimension of output 
% 2 Total number of binned values
% 3 Deals with minimum values
% 4 Deals with max values
% 5 Case where entries are equal to bin edges


function testbin_2d_data1(testCase)
% Test for dimension of output
	A = rand(500,2);
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	n = bin_2d_data(A,ed1,ed2);
	
	verifyEqual(testCase,size(n),[length(ed1)-1,length(ed2)-1]);%,'bin_2d_data:BadSizeOutput' );
end


function testbin_2d_data2(testCase)
%Test for number of binnned values

	A = rand(500,2);
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	n = bin_2d_data(A,ed1,ed2);
	
	verifyEqual(testCase,sum(sum(n)),length(A));%,'bin_2d_data:BadTotalOutput' );
end


function testbin_2d_data3(testCase)
%Test for checking of min values
	
	A = rand(500,2);
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	A(1,1) = -1;
	n = bin_2d_data(A,ed1,ed2);

	verifyWarning(testCase,@()bin_2d_data(A,ed1,ed2),'bin_2d_data:UncontainedExtremeValue');
	verifyWarning(testCase,@()bin_2d_data(A,ed1,ed2),'bin_2d_data:DoesntAddUp');
	
end


function testbin_2d_data4(testCase)
%Test for checking of max values

	A = rand(500,2);
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	A(1,1) = 2;
	n = bin_2d_data(A,ed1,ed2);

	verifyWarning(testCase,@()bin_2d_data(A,ed1,ed2),'bin_2d_data:UncontainedExtremeValue');
	
end


function testbin_2d_data5(testCase)
% Check total size when have values at edge of bins
	
	A = rand(500,2);
	ed1 = [0,0.5,1];
	ed2 = [0:0.1:1];
	A(1,:) = [0 1];
	
	n = bin_2d_data(A,ed1,ed2); % should get warning DoesntAddUp if d not workiong
	
	verifyEqual(testCase,sum(sum(n)),length(A));
end


% %% Optional file fixtures  
% function setupOnce(testCase)  % do not change function name
% % set a new path, for example
% end

% function teardownOnce(testCase)  % do not change function name
% % change back to original path, for example
% end