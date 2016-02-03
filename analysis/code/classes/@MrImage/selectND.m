function [selectionImage, selectionIndexArray, unusedVarargin] = selectND(this, varargin)
% Prototype for select-method of n-dimensional image data using dimInfo
%
%   Y = MrImage()
%   selectionImage = Y.selectND(type', 'index'/'label', 'invert', true/false, ...
%             'dimLabel1', arrayIndicesDim1/samplingPointsDim1, ...,
%               ...
%              'dimLabelK', arrayIndicesDimK/samplingPointsDimK, ...)
%
%
% This is a method of class MrImage.
%
%   PropertyName/Value pairs
%   General parameters
%   'type'      'index' or 'label'
%               defines how selection elements should be
%               interpreted as array indices or sampling points
%   'invert'    true or false (default)
%               if true, selection is inverted and given arrayIndices are
%               excluded from returned selection, based on
%               dimInfo-information about whole array
%
% OUT
%   selectionIndexArray     indexArray of selected samples in original
%                           dimInfo
%   selectionImage          dimInfo of specified selection, derived as
%                           subset from dimInfo
%   unusedVarargin          if specified, returns all input arguments that
%                           did not match a dimLabel/Value pair of dimInfo
%                           Note: If this output is omitted, select returns
%                           an error for every unknown dimension requested
%
% EXAMPLE
%   selectND
%
%   See also MrImage MrDimInfo.select
%
% Author:   Lars Kasper
% Created:  2016-01-31
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
returnUnusedVarargin = nargout >=3;

if returnUnusedVarargin
    [selectionDimInfo, selectionIndexArray, unusedVarargin] = ...
        this.dimInfo.select(varargin{:});
else
    % be strict about wrong varargin, return error for unused select dims
    [selectionDimInfo, selectionIndexArray] = ...
        this.dimInfo.select(varargin{:});
end

selectionImage = this.copyobj;
selectionImage.data = selectionImage.data(selectionIndexArray{:});
selectionImage.dimInfo = selectionDimInfo.copyobj();

selectionImage.update_geometry_dim_info('dependent', 'geometry');

