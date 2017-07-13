%% Unit Testing for MrDimInfo

% create test object
testCase = MrUnitTest;
% call individual test cases
res = run(testCase, 'MrDimInfo_constructor');
res = run(testCase, 'MrDimInfo_constructor_with_struct');

res = run(testCase, 'MrDimInfo_variant2');

% create test suite
import matlab.unittest.TestSuite;
% run all constructor tests
sC = TestSuite.fromClass(?MrUnitTest,'Tag','Constructor');
resultsC = run(sC);
% run all constructor tests
sV = TestSuite.fromClass(?MrUnitTest,'Tag','Variants');
resultsV = run(sV);
disp(table(resultsC));
disp(table(resultsV));
