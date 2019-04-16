function dataNdConcat = concat(this, dataNdArray, concatDim, tolerance)
%Concatenate an array of MrDataNd along one specified dimension
%
%   Y = MrDataNd()
%   dataNdConcat = Y.concat(dataNdArray, concatDim, tolerance)
%
% This is a method of class MrDataNd. It is very similar to combine with
% the difference that non-singleton dimensions can be concatenated (e.g.,
% volume 1-10 and 11-20). Multi-dimensional concatenation is not supported,
% because it would leave parts of the array empty (e.g., volume 1-10 of
% slice 1-9 concatenated with volume 11-20 of slice 10-20 would leave the
% "cross-terms" of the dim Matrix like slice 1-9 of volume 11-10 undefined.
%
% NOTE: Not the order of data in the array will define the concatenation order
%       but the actual values of the samplingPoints in dimInfo along the
%       concat dimension.
%
% IN
%   dataNdArray     cell(nDatasets,1) of MrDataNd to be concatenated
%                       OR
%                   single MrDataNd object. In this case, the input object
%                   and the calling object will be concatenated
%   concatDim       index or string (label) of dimension along which data
%                   should be concatenated
%   tolerance                   dimInfos are only combined, if their
%                               information is equal for all but the
%                               concatDim (because only one
%                               representation is retained for those,
%                               usually from the first of the dimInfos). 
%                               However, sometimes numerical precision,
%                               e.g., rounding errors, preclude the
%                               combination. Then you can increase this
%                               tolerance; 
%                               default: single precision (eps('single')
%                               ~1.2e-7)   
% OUT
%
% EXAMPLE
%   concat
%
%   See also MrDataNd MrDataNd.combine MrDimInfo.combine
 
% Author:   Lars Kasper
% Created:  2019-04-15
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

if nargin < 4
    tolerance = eps('single');
end

if ~iscell(dataNdArray)
    dataNdArray = {this, dataNdArray};
end

nImages = numel(dataNdArray);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Split all images in array along specified dimension
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iImage = 1:nImages
    I1Array = I1.split('splitDims', concatDim, 'tolerance', tolerance);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Combine all image arrays and reconcatenate!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note that not the order here will be important, but the actual value of
% the slice position in dimInfo
IArray = [I2Array;I1Array]; 

IConcat = IArray{1}.combine(IArray, 't');
IConcat.plot('imagePlotDim', {'x','y','t'}, 't',Inf, 'z', 5);