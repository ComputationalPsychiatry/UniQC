%% Unit Testing for MrDimInfo

% create test object
testCase = MrUnitTest;
% call individual test cases
res = run(testCase, 'MrDimInfo_constructor_error');
res = run(testCase, 'MrDimInfo_constructor_error_v2');
res = run(testCase, 'MrDimInfo_constructor_with_struct');
res = run(testCase, 'MrDimInfo_variant2');

% create test suite
import matlab.unittest.TestSuite;
% run all constructor tests
sC = TestSuite.fromClass(?MrUnitTest,'Tag','Constructor');
result = run(sC);
disp(table(result));
% run all constructor tests
sV = TestSuite.fromClass(?MrUnitTest,'Tag','Variants');
result = run(sV);
disp(table(result));
