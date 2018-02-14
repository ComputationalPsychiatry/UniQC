function this = MrDimInfo_split(this, testVariantsDimInfoSplit)
% Unit test for MrDimInfo split
%
%   Y = MrUnitTest()
%   run(Y, 'MrDimInfo_split')
%
% This is a method of class MrUnitTest.
%
% IN
%
% OUT
%
% EXAMPLE
%   MrDimInfo_split
%
%   See also MrUnitTest
%
% Author:   Saskia Bollmann
% Created:  2018-02-14
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

% construct MrDimInfo object from sampling points
dimInfo = this.make_dimInfo_reference(0);

switch testVariantsDimInfoSplit
    
    case 'singleDim'
        % split along single dimension
        splitDim = 5;
        nSplits = dimInfo.nSamples(splitDim);
        allDims = 1:dimInfo.nDims;
        keptDims = setdiff(allDims, splitDim);
        
        % split along splitDim
        [dimInfoArray, sfxArray, selectionArray] = dimInfo.split(splitDim);
        
        for n = 1:nSplits
            % expected solution
            % selection Array ('dimLabel', samplingPoint)
            expSolution.selectionArray{n,1} = {dimInfo.dimLabels{splitDim}, ...
                dimInfo.samplingPoints{splitDim}(n)};
            % sfx Array (_'dimLabel' 00samplingPoint)
            expSolution.sfxArray{n,1} = ['_', dimInfo.dimLabels{splitDim}, ...
                num2str(dimInfo.samplingPoints{splitDim}(n), '%04.0f')];
            % actual solution
            % retrieve only sampling points
            actSolution.dimInfoArraySamplingPoint(n) = dimInfoArray{n}.samplingPoints{splitDim};
        end
        
        % expected solution
        % all sampling points
        expSolution.dimInfoArraySamplingPoint = dimInfo.samplingPoints{splitDim};
        
        % actual solution
        % selection Array ('dimLabel', samplingPoint)
        actSolution.selectionArray = selectionArray;
        % sfx Array (_'dimLabel' 00samplingPoint)
        actSolution.sfxArray = sfxArray;
        
        % kept dimension
        warning('off', 'MATLAB:structOnObject');
        % expected solution
        expSolution.keptDimInfo = struct(dimInfo.get_dims(keptDims));
        % actual solution
        actSolution.keptDimInfo = struct(dimInfoArray{1}.get_dims(keptDims));
        warning('on', 'MATLAB:structOnObject');
        
    case 'twoDims'
        % split along two dimensions
        splitDim = [3, 5];
        nSplits = dimInfo.nSamples(splitDim);
        allDims = 1:dimInfo.nDims;
        keptDims = setdiff(allDims, splitDim);
        
        % split along splitDim
        [dimInfoArray, sfxArray, selectionArray] = dimInfo.split(splitDim);
        
        for n = 1:nSplits(1)
            for m = 1:nSplits(2)
                % expected solution
                % selection Array ('dimLabel', samplingPoint)
                expSolution.selectionArray{n,m} = ...
                    {dimInfo.dimLabels{splitDim(1)}, dimInfo.samplingPoints{splitDim(1)}(n), ...
                    dimInfo.dimLabels{splitDim(2)}, dimInfo.samplingPoints{splitDim(2)}(m)};
                % sfx Array (_'dimLabel' 00samplingPoint)
                expSolution.sfxArray{n,m} = ...
                    ['_', dimInfo.dimLabels{splitDim(1)}, ...
                    num2str(dimInfo.samplingPoints{splitDim(1)}(n), '%04.0f'), ...
                    '_', dimInfo.dimLabels{splitDim(2)}, ...
                    num2str(dimInfo.samplingPoints{splitDim(2)}(m), '%04.0f')];
                % actual solution
                % retrieve only sampling points
                actSolution.dimInfoArraySamplingPoint{n,m} = ...
                    [dimInfoArray{n,m}.samplingPoints{splitDim(1)}, ...
                    dimInfoArray{n,m}.samplingPoints{splitDim(2)}];
                % expected solution
                % all sampling points
                expSolution.dimInfoArraySamplingPoint{n,m} = ...
                    [dimInfo.samplingPoints{splitDim(1)}(n), ...
                    dimInfo.samplingPoints{splitDim(2)}(m)];
                
            end
        end
                
        % actual solution
        % selection Array ('dimLabel', samplingPoint)
        actSolution.selectionArray = selectionArray;
        % sfx Array (_'dimLabel' 00samplingPoint)
        actSolution.sfxArray = sfxArray;
        
        % kept dimension
        warning('off', 'MATLAB:structOnObject');
        % expected solution
        expSolution.keptDimInfo = struct(dimInfo.get_dims(keptDims));
        % actual solution
        actSolution.keptDimInfo = struct(dimInfoArray{1}.get_dims(keptDims));
        warning('on', 'MATLAB:structOnObject');
    case 'nonExistingDim'
        % split along non existing dim
        [dimInfoArray, sfxArray, selectionArray] = dimInfo.split(10);
        % actual solution
        warning('off', 'MATLAB:structOnObject');
        actSolution.dimInfoArray = cellfun(@struct, dimInfoArray);
        warning('on', 'MATLAB:structOnObject');
        % exptected solution
        warning('off', 'MATLAB:structOnObject');
        actSolution.dimInfoArray = struct(dimInfo);
        warning('on', 'MATLAB:structOnObject');
        
    case 'charSplitDim'
        splitDim = 5;
        splitChar = dimInfo.dimLabels{splitDim};
        
        % expected Solution
        [dimInfoArrayExp, sfxArrayExp, selectionArrayExp] = dimInfo.split(splitDim);
        warning('off', 'MATLAB:structOnObject');
        expSolution.dimInfoArray = cellfun(@struct, dimInfoArrayExp);
        warning('on', 'MATLAB:structOnObject');
        expSolution.sfxArray = sfxArrayExp;
        expSolution.selectionArray = selectionArrayExp;
        
        % actual Solution
        [dimInfoArrayAct, sfxArrayAct, selectionArrayAct] = dimInfo.split(splitChar);
        warning('off', 'MATLAB:structOnObject');
        actSolution.dimInfoArray = cellfun(@struct, dimInfoArrayAct);
        warning('on', 'MATLAB:structOnObject');
        actSolution.sfxArray = sfxArrayAct;
        actSolution.selectionArray = selectionArrayAct;
        
    case 'differentIndex'
        
end

this.verifyEqual(actSolution, expSolution, 'absTol', 10e-7);

end