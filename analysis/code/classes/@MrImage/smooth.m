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
imageType = 'magnitudeND';

switch imageType
    case 'is4D'
        thisAs4D = this.recast_as_MrImageSpm4D();
    case 'isNd'
        thisAs4D = this.split_into_MrImageSpm4D();
%        combine_from_MrImageSpm4D
        
        
        
        
       
        
        % cast to MrImageSpm4D, apply, cast back!
        % constructor for MrImageSpm4D from MrImage and vice versa
        % mrImageSpm4D = MrImageSpm4D(MrImage, convertComplexMode)
        % convertComplexMode = {'re/im', 'abs/phase'}
    case 'complex'
        % split into extra dimension magnitude/phase separately and smooth
        % then
        
        % or real and imaginary? ... warning?
    case 'magnitudeND' % all magnitude, but more than 4 non-singleton dimensions
        % x,y,z,t are smoothed as 4D volumes separarately, split along all
        % other dimensions
        this.wrap_spm_method(@smooth);
end


%% split (and recast) into applicable 4D-SPM images
        % smooth

%% smooth all MrImageSpm4D entities

%% reassemble smoothed images into one again