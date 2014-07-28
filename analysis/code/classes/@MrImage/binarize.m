function this = binarize(this, threshold, caseEqual)
% transforms image into binary image with pixels >= threshold set to 1
%(0 stays 0)
%
% NOTE: Nans and Infs set to 0.
%
%   Y = MrImage()
%   Y.binarize(threshold)
%
% This is a method of class MrImage.
%
% IN
%       threshold   thresholding value for image (default: 0)
%                   all pixels >= threshold will be set to 1, all others to
%                   0
%       caseEqual   'exclude' or 'include'
%                   'include' pixels with exact threshold value will be kept
%                             (default)
%                   'exclude' pixels with exact threshold value will be
%                             set to 0
% OUT
%       this        thresholded, binary image
%
% EXAMPLE
%   binarize
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-18
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
if nargin < 2
    threshold = 0;
end

if nargin < 3
    caseEqual = 'include';
end

% set appropriate voxels to 1
switch caseEqual
    case 'include'
        this.data(find(this.data>=threshold)) = 1;
    case 'exclude'
        this.data(find(this.data>threshold)) = 1;
end

% everything below 1 is set to 0
this.apply_threshold(1, 'include');

this.data(isinf(this.data)) = 0;

this.finish_processing_step('binarize');
