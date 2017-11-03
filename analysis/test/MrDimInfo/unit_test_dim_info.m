%% Unit Testing for MrDimInfo

% create test object
testCase = MrUnitTest;
% call individual test cases
res = run(testCase, 'MrDimInfo_constructor');

% create test suite
import matlab.unittest.TestSuite;
% run all constructor tests
sC = TestSuite.fromClass(?MrUnitTest,'Tag','Constructor');
resultsC = run(sC);
disp(table(resultsC));