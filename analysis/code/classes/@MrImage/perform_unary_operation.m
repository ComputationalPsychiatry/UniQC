function outputImage = perform_unary_operation(this, functionHandle, ...
    applicationDimensions, doApplicationLoopExplicitly)
% Performs unary operation (i.e. 1 input) on image for given dimension
%
%   Y = MrImage()
%   outputImage = perform_unary_operation(this, functionHandle, ...
%    applicationDimensions)
%
% This is a method of class MrImage.
%
% IN
%   functionHandle          handle of function to be applied to image (e.g.
%                           @diff, @mean)
%   applicationDimensions   Specifies on which subsets of the data the unary
%                           operation should be applied separately. Conversely, all
%                           other dimensions are looped over.
%                           one value: 1...4
%                               image dimension along which operation is
%                               performed (e.g. 4 = time, 3 = slices)
%                               default: The last dimension with more than one
%                               value is chosen
%                               (i.e. 3 for 3D image, 4 for 4D image)
%
%                               corresponds to Matlab usage of
%                               multi-dimensional functions, e.g. mean(X,4), std
%
%                           vector:
%                               e.g. [1,2]
%                               Data is partitioned into chunks of
%                               specified applicationDimensions, and
%                               operation is looped over all other image
%                               dimensions (e.g. slices and volumes for
%                               applicationDimensions=[1,2]
%
%                           keyword:
%                               '2D' == [1,2]
%                               '3D' == [1,2,3]
%                               't'  == 4
%
%                           '2D'
%                               certain functions expect a 2D input (e.g. image
%                               processing toolbox methods such as edge); with
%                               this option, the operation is performed for
%                               each 2D slice individually and looped over all
%                               slices and volumes
%
%   doApplicationLoopExplicitly
%                           false (default for single dimensions passed)
%                           for array functions that can handle dim-input
%                           directly (e.g. in-built Matlab mean, sum),
%                           data is permuted to applicationDimension as first dimension
%                           and then passed directly to functionHandle
%
%                           true
%                           data is re-partitioned within this function
%                           according to applicationDimension before passed
%                           on to functionHandle, e.g. for fit
%                           functionality
%
% OUT
%   outputImage             new MrImage with possibly new image dimensions
%
% EXAMPLE
%
%   %% 1. Compute difference images along time dimension
%   diffY = Y.perform_unary_operation(@diff, 4)
%
%   %% 2. Operations can also be arbitrarily concatenated: Compute mean
%   % difference image
%   meanDiffY =  Y.perform_unary_operation(@diff, 4).perform_unary_operation(...
%               @mean, 4)
%   %% 3. Perform 2D image operation per slice and volume
%   edgeY = Y.perform_unary_operation(@edge, '2D');
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
    applicationDimensions = ndims(this);
end

if ischar(applicationDimensions)
    switch lower(applicationDimensions)
        case '2d'
            applicationDimensions = [1 2];
        case '3d'
            applicationDimensions = [1 2 3];
        case 't'
            applicationDimensions = 4;
    end
end

if nargin < 4
    doApplicationLoopExplicitly = ...
        numel(applicationDimensions) > 1 || ...
        ischar(applicationDimensions);
end

outputImage = this.copyobj;

%% Reshape Data to 2D matrix, 1st one for chunks to apply function,
%  2nd one to loop over all other dimensions
if doApplicationLoopExplicitly
    
    nVoxels = this.geometry.nVoxels;
    iterationDimensions = setdiff(1:ndims(this), applicationDimensions);
    nChunks             = prod(nVoxels(iterationDimensions));
    
    nVoxelsChunk        = nVoxels(applicationDimensions);
    nVoxelsIterations   = nVoxels(iterationDimensions);
    
    nDimsChunk          = numel(nVoxelsChunk);
    
    % shuffle dimension of 1 chunk (data partition to apply function to) as
    % first ones, iteration dimensions after that, and reshape them to 2D
    iPermuteDims        = [applicationDimensions, iterationDimensions];
    inputAll2D          = reshape(...
        permute(this.data, iPermuteDims), ...
        [prod(nVoxelsChunk), nChunks]);
    
    percentCompleted = 0;
    fprintf('Completed %3.0d%%', percentCompleted);
    for iChunk = 1:nChunks
        
        % display progress
        if (iChunk/nChunks * 100) - percentCompleted > 1
            percentCompleted = round(iChunk/nChunks * 100);
            fprintf('\b\b\b\b%3.0d%%', percentCompleted);
        end
        
        % select chunk of data and reformat it for function input to
        if nDimsChunk > 1
            inputChunk  = reshape(inputAll2D(:,iChunk), nVoxelsChunk);
        else
            inputChunk  = inputAll2D(:,iChunk);
        end
        
        outputChunk = functionHandle(inputChunk);
        
        % pre-allocation of memory only possible after one calculation
        if iChunk == 1
            outputAll2D = zeros([numel(outputChunk), nChunks]);
        end
        
        % reshape output to 2D for temporary storage
        outputAll2D(:,iChunk) = outputChunk(:);
        
    end
    fprintf('\n');
    
    % Restore original data dimensions
    outputImage.data = ipermute(...
        reshape(outputAll2D, [nVoxelsChunk, nVoxelsIterations]), ...
        iPermuteDims);
    
else
    % classical
    % Assumption: function acts automatically on 1st dimension, collapses
    % data size over that dimension
    %
    % permutes data for functions that take other 2nd input arguments for
    % application dimension, such as std(X,0,dim) or diff(X,n,dim)
    
    tempDimOrder = 1:4;
    tempDimOrder(1) = applicationDimensions;
    tempDimOrder(applicationDimensions) = 1;
    
    outputImage.data = permute(outputImage.data, tempDimOrder);
    
    % Perform operation
    outputImage.data = permute(functionHandle(outputImage.data), ...
        tempDimOrder);
end

% Update image geometry
outputImage.geometry.update('nVoxels', size(outputImage.data), ...
    'resolution_mm', outputImage.geometry.resolution_mm);
outputImage.name = sprintf('%s( %s )', func2str(functionHandle), ...
    outputImage.name);