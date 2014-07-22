function this = compute_tissue_probability_maps(this)
% Computes tissue probability maps
%
%   Y = MrSeries()
%   Y.compute_tissue_probability_maps(inputs)
%
% This is a method of class MrSeries.
%
% IN
%
% OUT
%
% EXAMPLE
%   compute_tissue_probability_maps
%
%   See also MrSeries MrImage segment spm_preproc
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-22
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
inputImage = this.parameters.compute_tissue_probability_maps.inputImage;% find input image...
tissueTypes = this.parameters.compute_tissue_probability_maps.tissueTypes;

mapOutputSpace              = 'native';
deformationFieldDirection   = 'both';
doBiasCorrection            = false;

this.init_processing_step('compute_tissue_probability_maps');

[this.tissueProbabilityMaps, deformationFields, biasField] = ...
   inputImage.segment(tissueTypes, mapOutputSpace, deformationFieldDirection, ...
       doBiasCorrection);
   
this.finish_processing_step('compute_tissue_probability_maps');