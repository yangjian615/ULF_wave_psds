% Run tests! For some reason the runtests(pwd) command doesn't work so here's a workaround

% set up directory paths to and from testing subdirectory
filedir = pwd;
testdir = strcat(filedir,'/testing/');

% list of all test files. See files for subtests
suite = {...
	'testbin_2d_data',...
	'test_linlinhist3',...
	'test_linloghist3',...
		};
		
% change to test directory
cd(testdir);
addpath(filedir);

% run tests!
results = runtests(suite)

% back to original directory
cd(filedir);