function this = realign(this)
% Realigns all 3D images in 4D data to each other, then to the mean
% Uses SPM's realign: estimate+rewrite functionality
%
%   MrSeries = realign(MrSeries)
%
% This is a method of class MrSeries.
%
% IN
%   MrImage.data
%   MrImage.parameters.realign.*
%   most SPM realign est/reslice parameters, enforcing congruency between 
%   est/reslice and ignoring file naming options:
%
%   quality         0..1, estimation quality, share of voxels included in estimation
%                   default: 0.9
%   separation      separation distance (mm) between evaluated image points in estimation
%                   default: 4
%   smoothingFwhm   FWHM (mm) of Gaussian smoothing kernel used for estimation
%                   default: 5
%   realignToMean   boolean; if true, 2-pass procedure, registering to mean
%                   default: true
%   interpolation   degree of b-spline interpolation for estimation and reslicing
%                   default: 7
%   wrapping        fold-over direction (phase encode)
%                   default: [0 0 0] % none
%   weighting       weighting image for estimation
%                   can be filename or MrImage
%                   default: '' % none
%   masking         mask incomplete timeseries?
%                   default: true
% OUT
%
% EXAMPLE
%   realign
%
%   See also MrSeries MrImage MrImage.realign

% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-01
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

this.init_processing_step('realign');
this.data.realign(this.parameters.realign);
this.finish_processing_step('realign', this.data);