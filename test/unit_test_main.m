%% Run complete unit test
% create test suite
import matlab.unittest.TestSuite;
% run complete test suit
UTall = TestSuite.fromClass(?MrUnitTest);
resultsAll = run(UTall);
disp(table(resultsAll));

%% Run test for MrDimInfo
UTDimInfo = TestSuite.fromClass(?MrUnitTest,'Tag','MrDimInfo');
resultsDimInfo = run(UTDimInfo);
disp(table(resultsDimInfo));

% run individual test for MrDimInfo
% create test object
testCase = MrUnitTest;
% call individual test cases
res = run(testCase, 'MrDimInfo_constructor');
res = run(testCase, 'MrDimInfo_get_add_remove');
res = run(testCase, 'MrDimInfo_split');
res = run(testCase, 'MrDimInfo_select');
res = run(testCase, 'MrDimInfo_load_from_file');
res = run(testCase, 'MrDimInfo_load_from_mat');
res = run(testCase, 'MrDimInfo_permute');

%% Run test for MrAffineTransformation
UTaffineTransformation = TestSuite.fromClass(?MrUnitTest,'Tag','MrAffineTransformation');
resultsaffineTransformation = run(UTaffineTransformation);
disp(table(resultsaffineTransformation));

%% Run test for MrImageGeometry
UTImageGeometry = TestSuite.fromClass(?MrUnitTest,'Tag','MrImageGeometry');
resultsImageGeometry = run(UTImageGeometry);
disp(table(resultsImageGeometry));

% call individual test cases
res = run(testCase, 'MrImageGeometry_constructor');
res = run(testCase, 'MrImageGeometry_load_from_file');
res = run(testCase, 'MrImageGeometry_create_empty_image');

%% Run test for MrDataNd
UTDataNd = TestSuite.fromClass(?MrUnitTest,'Tag','MrDataNd');
resultsDataNd = run(UTDataNd);
disp(table(resultsDataNd));

res = run(testCase, 'MrDataNd_select');
