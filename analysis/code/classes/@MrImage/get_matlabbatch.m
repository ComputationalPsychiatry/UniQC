function matlabbatch = get_matlabbatch(this, module, varargin)
% Returns matlabbatch to perform spm-processing with an MrImage. Fills out
% all necessary file parameters and options vor different modules, e.g.
% realignment, smoothing
%
%   matlabbatch = get_matlabbatch(MrImage, module, varargin)
%
% This is a method of class MrImage.
%
% IN
%   module      'realign', 'smooth' different SPM preprocessing routines
%   varargin    limited set of options to be determined for each module
%               e.g. fwhm for smoothing
% OUT
%   matlabbatch spm matlabbatch that would be executed if module was performed,
%               can be scrutinized via
%               spm_jobman('interactive', matlabbatch)
%
% EXAMPLE
%   get_matlabbatch
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-02
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

pathThis = fileparts(mfilename('fullpath'));
fileMatlabbatch = fullfile(pathThis, 'matlabbatch', ...
    sprintf('mb_%s.m', module));
run(fileMatlabbatch);

switch module
    case 'smooth'
        fwhmMillimeter = varargin{1};
        
        % load and adapt matlabbatch
        matlabbatch{1}.spm.spatial.smooth.fwhm = fwhmMillimeter;
        matlabbatch{1}.spm.spatial.smooth.data = ...
            cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], Inf));
    case 'realign'
        quality = varargin{1};
        % load and adapt matlabbatch
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = ...
            quality;
        matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = ...
            cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], Inf));
    case 'resize'
        fnTargetGeometry = varargin{1};
        matlabbatch{1}.spm.spatial.coreg.write.ref = ...
            cellstr(fnTargetGeometry);
        matlabbatch{1}.spm.spatial.coreg.write.source = ...
            cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], Inf));
    case 'segment'
        tissueTypeArray = varargin{1};
        imageOutputSpace = varargin{2};
        deformationFieldDirection = varargin{3};
        
        % set spm path for tissue probability maps correctly
        pathSpm = fileparts(which('spm'));
        nTissues = numel(matlabbatch{1}.spm.spatial.preproc.tissue);
        for iTissue = 1:nTissues
            matlabbatch{1}.spm.spatial.preproc.tissue(iTissue).tpm = ...
                regexprep(matlabbatch{1}.spm.spatial.preproc.tissue(iTissue).tpm, ...
                '/Users/kasperla/Documents/code/matlab/spm12b', pathSpm);
        end
        
        
        % set which tissue types shall be written out and in which space
        allTissueTypes = {'GM', 'WM', 'CSF', 'bone', 'fat', 'air'};
        indOutputTissueTypes = find(ismember(lower(allTissueTypes), ...
            lower(tissueTypeArray)));
        for iTissueType = indOutputTissueTypes
            switch lower(imageOutputSpace)
                case 'native'
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).native = [1 0];
                case {'mni', 'standard', 'template', 'warped'}
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).warped = [1 0];
                case 'both'
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).native = [1 0];
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).warped = [1 0];
            end
        end
        
        % set which deformation field shall be written out
        switch deformationFieldDirection
            case 'none'
                matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
            case 'forward'
                matlabbatch{1}.spm.spatial.preproc.warp.write = [1 0];
            case {'backward', 'inverse'}
                matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
            case {'both', 'all'}
                matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
        end
        
        % set to save bias-corrected image or only bias field
        if doBiasCorrection
            matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
        end
        
        % set data as well
        matlabbatch{1}.spm.spatial.preproc.channel.vols = ...
            cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], 1));
end