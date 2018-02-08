function this = MrDataNd_arithmetic_operation(this, testArithmeticOperation)
%ONE_LINE_DESCRIPTION
%
%   Y = MrUnitTest()
%   run(Y, 'MrDataNd_arithmetic_operation')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDataNd_arithmetic_operation
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann
% Created:  2018-02-08
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

% create two MrDataNd objects
% seed random number generator
rng(1);
nSamples = [24, 24, 6, 5, 4, 3];
dataMatrixX = randn(nSamples);
dataMatrixY = randn(nSamples(1:2));
% 6D image
x = MrDataNd(dataMatrixX);
% 2D image
y = MrDataNd(dataMatrixY);
% scalar
scalarValue = 3;

% define expected solution
expSolution = dataMatrixX;

switch testArithmeticOperation
    case 'plus/minus'
        % subtract and add two images and test multiplication with scalar
        difference = x - y;
        difference = difference .* scalarValue;
        % define actual solution
        actSolution = (difference + y .*scalarValue) ./scalarValue;
    case 'times/rdivide'
        % divide and multiply two images
        product = x .* y;
        product = product + scalarValue;
        % define actual solution
        actSolution = (product - scalarValue)./y;
end



% verify equality of expected and actual solution
% import matlab.unittests to apply tolerances for objects
this.verifyEqual(actSolution.data, expSolution, 'absTol', 10e-7);


end