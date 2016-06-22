function outputImage = perform_binary_operation(this, otherImage, ...
    functionHandle)
% Performs binary operation (i.e. 2 inputs) on this and a second image
% for given dimension and returns a new output image
%
% NOTE: If voxel dimensions of 2nd image do not match - or a scalar is
% given as 2nd argument - data in the 2nd argument is automatically
% replicated to match this image geometry.
%
%   Y = MrDataNd()
%   outputImage = perform_binary_operation(this, otherImage, ...
%   functionHandle)
%
% This is a method of class MrDataNd.
%
% IN
%   otherImage              2nd operand for binary operation
%   functionHandle          handle of function to be applied to images (e.g.
%                           @plus, @minus, @times and @rdivide for the 4 
%                           arithmetic operations )
%
% OUT
%   outputImage             new MrDataNd with possibly new image dimensions,
%                           output of binary operation performed on this
%                           and otherImage
% EXAMPLE
%
%   % Compute difference of 2 images
%		Y = MrDataNd();
%		Z = MrDataNd();
%		X = Y.perform_binary_operation(Z, @minus);
%
%	% Scale image (multiply) by a factor of 3
%		Y = MrDataNd();
%		Y = Y.perform_binary_operation(3, @mult)
%
%	% Compute ratio of 2 images
%		Y 			= MrDataNd();
%		Z 			= MrDataNd();
%		ratioYZ 	= Y.perform_binary_operation(Z, @rdivide);
%	
%
%
%   See also MrDataNd perform_unary_operation
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-13
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
% $Id: perform_binary_operation.m 80 2014-11-04 23:39:16Z lkasper $

% binary operation with scalar etc. => make MrDataNd first
if ~isa(otherImage, 'MrDataNd')
    otherData = otherImage;
    otherName = 'dataMatrix';
else
    otherData = otherImage.data;
    otherName = otherImage.name;
end

nSamplesOther = size(otherData);
nSamplesOther((end+1):this.dimInfo.nDims) = 1;
iSingletonDim = find(nSamplesOther == 1); % to be replicated!

% if sizes do not match, perform 
% a) replication of singleton dimensions (i.e. 1 slice => N x replicated)
% b) interpolation of non-singleton dimensions (e.g. 5 slices => 10 slices)
%       => TODO: respect FOV instead of matrix sizes?

factorsReplication = ones(1, this.dimInfo.nDims);
factorsReplication(iSingletonDim) = this.dimInfo.nSamples(iSingletonDim);

% a) replication of singleton dimensions (i.e. 1 slice => N x replicated)
otherData = repmat(otherData, factorsReplication);

% b) interpolation of non-singleton dimensions (e.g. 5 slices => 10 slices)
otherData  = resizeNd(otherData, this.dimInfo.nSamples);

outputImage 	 	= this.copyobj();

% already store replicated data of otherImage in output image to save some memory
outputImage.data 	= otherData;

outputImage.data 	= functionHandle(this.data, outputImage.data);

outputImage.info{end+1,1} = sprintf('%s( %s, %s )', func2str(functionHandle), ...
    outputImage.name, otherName);