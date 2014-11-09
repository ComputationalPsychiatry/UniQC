function matlabbatch = get_matlabbatch(this, module, varargin)
% Returns matlabbatch to perform spm-processing with an MrSeries.
% Fills out all necessary file parameters and options for different
% modules, e.g. specification of the first level design
%
% matlabbatch = get_matlabbatch(MrSeries, module, varargin)
%
% This is a method of class MrSeries.
%
% IN
%   module      'specify_1st_level'
%   varargin    limited set of options to be determined for each module
%
% OUT
% matlabbatch   spm matlabbatch that is executed when the module is
%               performed
%               can be scrutinized via spm_jobman('interactive',
%               matlabbatch)
%
%
% EXAMPLE
%   get_matlabbatch('specify_1st_level');
%
%   See also MrSeries
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2014-11-07
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

pathThis = fileparts(mfilename('fullpath'));
fileMatlabbatch = fullfile(pathThis, 'matlabbatch', ...
    sprintf('mb_%s.m', module));
run(fileMatlabbatch);

switch module
    case 'specify_1st_level'
        
        % set SPM directory
        spmDirectory = fullfile(this.glm.parameters.save.path, ...
            this.glm.parameters.save.spmDirectory);
        matlabbatch{1}.spm.stats.fmri_spec.dir = {spmDirectory};
        
        % set timing from MrGLM
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = ...
            this.glm.timingUnits;
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = ...
            this.glm.repetitionTime;
        
        % add scans
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans =  ...
        cellstr(spm_select('ExtFPList', this.data.parameters.save.path, ...
            ['^' this.data.parameters.save.fileUnprocessed], Inf)); 
        
        % add multiple conditions
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = ...
            cellstr(fullfile(this.glm.parameters.save.path, 'Conditions.mat'));
        
        % add multiple regressors
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = ...
            cellstr(fullfile(this.glm.parameters.save.path, 'Regressors.mat'));
        
        % set hrf derivatives
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = ...
            this.glm.hrfDerivatives;
        
end
