function this = smooth(this, fwhmMillimeter)
% smoothes ND MrImage using Gaussian kernel and via SPM functionality
%
%   Y = MrImage()
%   Y.smooth(inputs)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   smooth
%
%   See also MrImage MrImageSpm4D.smooth
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-04-26
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

%% Decide upon which type of ND image this is

switch imageType
    case 'is4D'
        thisAs4D = this.recast_as_MrImageSpm4D();
    case 'isNd'
        thisAs4D = this.split_into_MrImageSpm4D()
%        combine_from_MrImageSpm4D
        
        
        
        
       
        
        % cast to MrImageSpm4D, apply, cast back!
        % constructor for MrImageSpm4D from MrImage and vice versa
        % mrImageSpm4D = MrImageSpm4D(MrImage, convertComplexMode)
        % convertComplexMode = {'re/im', 'abs/phase'}
    case 'complex'
        % smooth magnitude and phase separately
        
        % or real and imaginary? ... warning?
    case 'magnitudeND' % all magnitude, but more than 4 non-singleton dimensions
        % x,y,z,t are smoothed as 4D volumes separarately, split along all
        % other dimensions
end

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


%% first realign on estimation, then apply to all (other?) dimensions
%   estimationImage = echo_comb(abs(image5D)) % has to be 4D
%   rp = estimationImage.realign()
%   image5D.realign(rp)

% realign({timeDimension}, ... % if not t, 4th dim will be taken


%% realign every entry of one dim differently
% splitDimensionWithSeparateRealignmentRuns = 'tag';
% combinationFunction = @id
% image5D.realign(splitDimensionWithSeparateRealignmentRuns, ...
%           combinationFunction);

% estI1 = combinationFunction(image5D.select('tag', 1));
% estI2 = combinationFunction(image5D.select('tag', 2));
%   rp1 = estI1.realign();
%   rp2 = estI2.realign();
% image5D.realign(rp1, 'tag', 1);
% image5D.realign(rp2, 'tag', 2);


%% split (and recast) into applicable 4D-SPM images
        % smooth

%% smooth all MrImageSpm4D entities

%% reassemble smoothed images into one again