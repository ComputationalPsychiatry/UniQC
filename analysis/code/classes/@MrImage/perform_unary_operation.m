function this = perform_unary_operation(this, functionHandle, ...
    applicationDimension)
% Performs unary operation (i.e. 1 input) on image for given dimension
%
%   Y = MrImage()
%   Y.perform_unary_operation(inputs)
%
% This is a method of class MrImage.
%
% IN
%   functionHandle          handle of function to be applied to image (e.g.
%                           @diff, @mean)
%   applicationDimension    image dimension along which operation is
%                           performed (e.g. 4 = time, 3 = slices)
%                           default: The last dimension with more than one
%                           value is chosen 
%                           (i.e. 3 for 3D image, 4 for 4D image)
%
% OUT
%   this                MrImage with possibly new image dimensions
% EXAMPLE
%   perform_unary_operation
%
%   See also MrImage
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-02
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

% maximum dimension with
if nargin < 3
    applicationDimension = find(this.geometry.nVoxels>1, 'last');
end

% permutes data for functions that take other 2nd input arguments for
% application dimension, such as std(X,0,dim) or diff(X,n,dim)

tempDimOrder = 1:4;
tempDimOrder(1) = applicationDimension;
tempDimOrder(applicationDimension) = 1;

dataTemp = permute(this.data, tempDimOrder);

% Perform operation
this.data = permute(functionHandle(dataTemp, applicationDimension), ...
    tempDimOrder);

% Update image geometry
this.geometry.load([], 'nVoxels', size(this.data)); 
