function outputImage = kfilter(this, filterType, applicationDimensions)
% Filters by multiplication of a specified window function in k-space
%
%   Y = MrDataNd()
%   outputImage = Y.kfilter(filterType, applicationDimensions)
%
% This is a method of class MrDataNd.
%
% IN
%   filterType  string of filter to be applied, possible values are
%               'hamming' (default)
%               'hann'
%   applicationDimensions
%               '2D' or '3D'
%                   default: '2D' for single slices, '3D' otherwise
%               '2D' performs the filter slice-wise with the same filter,
%               '3D' performs the filter for a 3D symmetric version of the
%                    filter
%
% OUT
%
% EXAMPLE
%   kfilter
%
%   See also MrDataNd
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-11-07
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

is3D = ndims(this) >= 2;

if nargin < 2
    filterType = 'hamming';
end

if nargin < 3
    if is3D
        applicationDimensions = '3D';
    else
        applicationDimensions = '2D';
    end
end

funFilter = str2func(filterType);
dimInfoFilter = this.dimInfo.copyobj();

% column vector * row vector = matrix coordinate-wise product
filterMatrix = reshape(funFilter(this.dimInfo.nSamples(1)), [],1)*...
    reshape(funFilter(this.dimInfo.nSamples(2)), 1, []);

% replicate same filter for all slices
if is3D
    filterMatrix = repmat(filterMatrix, 1, 1, this.dimInfo.nSamples(3));
    dimInfoFilter.remove_dims(4:dimInfoFilter.nDims);
    
    switch applicationDimensions
        case '3D'
            % create the filter in 3rd dimension by replicating in other 2
            % dims and multiplying with slice-replicated 2D-filter
            filterMatrixThirdDim = reshape(funFilter(this.dimInfo.nSamples(3)), 1, 1, []);
            filterMatrix = filterMatrix.*repmat(filterMatrixThirdDim,...
                dimInfoFilter.nSamples(1), dimInfoFilter.nSamples(2), 1);
        case '2D'
            % everything fine, we just replicated for all slices
    end
    
else
    dimInfoFilter.remove_dims(3:dimInfoFilter.nDims);
end


filterImage = MrImage(filterMatrix, 'dimInfo', dimInfoFilter);
outputImage = k2image(image2k(this, applicationDimensions).*filterImage, ...
    applicationDimensions);