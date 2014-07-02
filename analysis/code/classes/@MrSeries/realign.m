function this = realign(this)
% Realigns all 3D images in 4D data to each other, then to the mean
% Uses SPM's realign: estimate+rewrite functionality
%
%   MrSeries = realign(MrSeries)
%
% This is a method of class MrSeries.
%
% IN
%
% OUT
%
% EXAMPLE
%   realign
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-01
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

this.init_processing_step('realign');
matlabbatch = this.get_matlabbatch('realign');
spm_jobman('run', matlabbatch);
this.finish_processing_step('realign');

