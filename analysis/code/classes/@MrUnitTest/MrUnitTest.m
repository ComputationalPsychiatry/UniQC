classdef MrUnitTest < matlab.unittest.TestCase
    % Implements unit testing for MrClasses
    %
    % EXAMPLE
    %   MrUnitTest
    %
    %   See also
    %
    % Author:   Saskia Bollmann & Lars Kasper
    % Created:  2017-07-07
    % Copyright (C) 2017 Institute for Biomedical Engineering
    %                    University of Zurich and ETH Zurich
    %
    % This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
    % under the terms of the GNU General Public License (GPL), version 3.
    % You can redistribute it and/or modify it under the terms of the GPL
    % (either version 3 or, at your option, any later version).
    % For further details, see the file COPYING or
    %  <http://www.gnu.org/licenses/>.
    %
    % $Id: new_class2.m 354 2013-12-02 22:21:41Z kasperla $
    
    methods (Test, TestTags = {'Constructor', 'MrDimInfo'})
        function MrDimInfo_constructor(testCase)
            % Unit test for MrDimInfo Constructor via resolutions...
            % (variant (1) in MrDimInfo)
            samplingPoints5D = ...
                {-111:1.5:111, -111:1.5:111, -24:1.5:24, 0:0.65:300.3, 1:4};
            dimInfo = MrDimInfo(...
                'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
                'units', {'mm', 'mm', 'mm', 's', ''}, ...
                'samplingPoints', samplingPoints5D);
            
            % define actual solution
            actSolution = dimInfo;
            % load expected solution
            classesPath = get_path('classes');
            solutionFileName = fullfile(classesPath, '@MrUnitTest' , 'dimInfo.mat');
            expSolution = load(solutionFileName);
            expSolution = expSolution.dimInfo;
            % compare solutions
            testCase.verifyEqual(...
                actSolution,...
                expSolution);
        end
        
        function MrDimInfo_constructor_with_struct(testCase)
            % Unit test for MrDimInfo Constructor via resolutions (warning off)
            % (variant (1) in MrDimInfo)
            samplingPoints5D = ...
                {-111:1.5:111, -111:1.5:111, -24:1.5:24, 0:0.65:300.3, [1, 2, 4]};
            dimInfo = MrDimInfo(...
                'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
                'units', {'mm', 'mm', 'mm', 's', ''}, ...
                'samplingPoints', samplingPoints5D);
            dimInfo2 = MrDimInfo(...
                'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
                'units', {'mm', 'mm', 'mm', 's', ''}, ...
                'samplingPoints', samplingPoints5D);
            % define actual solution
            % warning off for struct to object
            warning('off', 'MATLAB:structOnObject');
            actSolution = struct(dimInfo);
            % define expected solution
            expSolution = struct(dimInfo2);
            % warning on for struct to object
            warning('on', 'MATLAB:structOnObject')
            % compare solutions
            testCase.verifyEqual(...
                actSolution,...
                expSolution);

            
        end
        
    end % methods 'Constructor'
    
    
    methods (Test, TestTags = {'Variants', 'MrDimInfo'})
        function MrDimInfo_variant2(testCase)
            % Unit test for MrDimInfo Variant 2
            
            % Initialize MrDimInfo via resolutions (variant (1) in MrDimInfo)
            samplingPoints5D = ...
                {0:0.1:10, 0:10, 0:1:10, 0:1:10, 0:10};
            expSolution = MrDimInfo(...
                'dimLabels', {'x', 'y', 'z', 't', 'coil'}, ...
                'units', {'mm', 'mm', 'mm', 's', ''}, ...
                'samplingPoints', samplingPoints5D);
            
            % Initialize MrDimInfo via nSamples + ranges (variant (2))
            actSolution = MrDimInfo(...
                'dimLabels', expSolution.dimLabels, ...
                'units', expSolution.units, ...
                'nSamples', expSolution.nSamples, ...
                'ranges', expSolution.ranges);
            
            % compare solutions
            testCase.verifyEqual(...
                actSolution,...
                expSolution);
        end
        
    end % methods 'Variants'
    
    
end
