function imageSpm4DArray = split_into_MrImageSpm4D(this, dimLabelsSpm4D)
% Splits high dimensional MrImage (>4) into array of 4D MrImageSpm4D
% objects to be used for SPM interfacing
%
%   Y = MrImage(); % >4 dimensions
%   imageSpm4DArray = Y.split_into_MrImageSpm4D(inputs)
%
% This is a method of class MrImage.
%
% IN
%   dimLabelsSpm4D      cell(1,4) of dimLabels that shall represent the 1st
%                       four dimensions that will be in each element of the 
%                       output 4D SPM-compatible image array
%                       default: {'x','y','z','t'} 
%                       NOTE: If less than 4 dimensions are specified, the
%                             remaining up to 4th dimension is included in
%                             the 4D images
%                             e.g.
%                               specified: {'x','y','z','t'}
%                               actual dimLabels:  {'x','z','echo', 'y', 'coil'}
%                               => {'x','y','z','echo'} will be in 4D image
%                       NOTE2: If certain labels do not exist, the
%                              existing dimensions later in the array are
%                              moved up in their dimension
%                               e.g.,
%                               specified: {'x','y','z','t'}
%                               actual dimLabels:  {'x','y','coil', 't', 'echo'}
%                               => {'x','y','t','coil'} will be in 4D image
% 
% OUT
%   imageSpm4DArray
%
% EXAMPLE
%   split_into_MrImageSpm4D
%
%   See also MrImage
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-03
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
% $Id$

if nargin < 2
    dimLabelsSpm4D = {'x','y','z','t'};
end

%% permute dimLabelsSpm4D as first 4 dimensions 
permutedThis = this.permute(this.dimInfo.get_dim_index(dimLabelsSpm4D));

%% split along all higher dimensions, keep chunks of 1st four together
imageSpm4DArray = permutedThis.split('splitDims', 5:this.dimInfo.nDims);
for iImage = 1:nImages
    imageSpm4DArray{iImage} = imageSpm4DArray{iImage}.recast_as_MrImageSpm4D;
end