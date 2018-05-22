function this = realign(this, varargin)
% Realigns n-dimensional image according to representative derived 4D image(s), 
% and applies resulting realignment parameters to respective subsets of the
% n-d image
%
%   Y = MrImage()
%   Y.realign(representationType, splitDimensions)
%
% This is a method of class MrImage.
%
% IN
%
% OUT
%
% EXAMPLE
%   realign
%
%   See also MrImage MrImage.wrap_spm_method MrImageSpm4D.realign
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-05-21
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

defaults.representationType = 'sos'; %'abs'
[args, argsUnused] = propval(defaults, varargin);

methodHandle = @realign;
methodParameters = varargin;
representationIndexArray = {};
representationMapping = @abs;
applicationIndexArray = {};
this.wrap_spm_method(methodHandle, methodParameters, ...
 splitDimensions, representationIndexArray, representationMapping, ...
 applicationIndexArray)
    

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



%% first realign on estimation, then apply to all (other?) dimensions
%   estimationImage = echo_comb(abs(image5D)) % has to be 4D
%   rp = estimationImage.realign()
%   image5D.realign(rp)

% realign({timeDimension}, ... % if not t, 4th dim will be taken


