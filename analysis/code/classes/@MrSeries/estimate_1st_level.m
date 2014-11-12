function this = estimate_1st_level(this)
% Estimates the specified SPM.mat matrix
%
%   Y = MrSeries()
%   Y.estimate_1st_level()
%
% This is a method of class MrSeries.
%
% IN
%
% OUT
%
% EXAMPLE
%   estimate_1st_level
%
%   See also MrSeries MrSeries.specify_1st_level()
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-10
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
% $Id: new_method2.m 354 2013-12-02 22:21:41Z kasperla $

% init processing step
this.init_processing_step('estimate_1st_level');

spmDirectory = fullfile(this.glm.parameters.save.path, this.glm.parameters.save.spmDirectory);
matlabbatch = this.get_matlabbatch('estimate_1st_level', spmDirectory);
save(fullfile(this.data.parameters.save.path, 'matlabbatch.mat'), ...
            'matlabbatch');
spm_jobman('run', matlabbatch);