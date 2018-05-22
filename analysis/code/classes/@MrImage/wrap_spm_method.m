function this = wrap_spm_method(this, methodHandle, varargin)
% Applies SPM-related method of MrImageSpm4D to a higher-dimensional MrImage ...
% by deciding on how to split data into 4D chunks and which ones to use as
% a representation for SPM to execute the method, and on which ones to
% apply the method
%
%   Y = MrImage()
%   Y.wrap_spm_method(this, methodHandle, 'paramName', paramValue, ...)
%
% This is a method of class MrImage.
%
% NOTE:     Splitting into 4D MrImage is always performed on all but
%           {'x','y','z','t'} dimensions
%
% IN
%   methodHandle    string or @handle to method of MrImageSpm4D to be
%                   executed
%   
%   propName/Value pairs:
%
%   methodParameters 
%                   additional input parameters to that method
%   representationIndexArray
%                   groups of indices that should (after a suitable
%                   mapping) represent 4D data chunks to be put into the
%                   SPM method
%   representationMapping
%                   function handle that maps the indices in representationIndexArray
%                   to a 4D representation of the data for SPM
%   applicationIndexArray
%                   indices referring to the data chunks in representationIndexArray
%                   that shall be transformed by the same mapping SPM
%                   estimated for the those representatives
%
%   splitDimensions
%
% OUT
%
% EXAMPLE
%   wrap_spm_method
%
%   See also MrImage
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-22
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
defaults.methodParameters = {};
defaults.representationIndexArray = {};
defaults.representationMapping = @(x) x;
defaults.applicationIndexArray = {};

args = propval(varargin, defaults);

strip_fields(args);

%% general wrapper ND -> SPM 3D/4D
% function(spmParameters, spmCombination4DDimensions, spmtransformationDimensions, ...
% functionHandleCombination, estimationDimension, applicationDimension
% realign({quality, splineOrder}, {'x','y','z','t'}, {'coil'}, ...
% @(x) sqrt(sum(x.^2))), {'x','y','z','t'...coil.^2}

% realign complex 4D data
% {x,y,z,t} ->  abs({x,y,z,t}) -> rp [estimationDimension/transformationFunction]
% rp -> {x,y,z,t}   [applicationDimensions]
%
% realign complex 5D data
% {x,y,z,t,echo} -> echo_comb(abs({x,y,z,t}, {echo})
%
% sliderViewerNd: combinationDimensions, loopDimensions/splitDimensions
%                 combinationFunction, visualizationFunction/spmFunction

% complex{x,y,z,t} -> abs, angle(complex{x,y,z,t} -> smooth -> combine
% (complex)
% image5D -> split(splitDimensions) -> loop over smooth(applicationDimension)
% -> combine(splitDimensions)

% -> needs MrImage.combine!!! (dimInfo and data combination!, affineGeometry
% consistency check!...request reslice, if not!)
