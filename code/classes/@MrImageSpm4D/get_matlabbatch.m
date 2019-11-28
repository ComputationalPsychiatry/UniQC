function matlabbatch = get_matlabbatch(this, module, varargin)
% Returns matlabbatch to perform spm-processing with an MrImage. Fills out
% all necessary file parameters and options for different modules, e.g.
% realignment, smoothing
%
%   matlabbatch = get_matlabbatch(MrImage, module, varargin)
%
% This is a method of class MrImage.
%
% IN
%   module      different SPM preprocessing routines, e.g., 'realign', 'smooth' 
%   varargin    struct or property name/value pairs, set of SPM options to 
%               be determined for each module e.g. fwhm for smoothing
% OUT
%   matlabbatch spm matlabbatch that would be executed if module was performed,
%               can be scrutinized via
%               spm_jobman('interactive', matlabbatch)
%
% EXAMPLE
%   get_matlabbatch
%
%   See also MrImage

% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-02
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


pathThis = fileparts(mfilename('fullpath'));
fileMatlabbatch = fullfile(pathThis, 'matlabbatch', ...
    sprintf('mb_%s.m', module));
run(fileMatlabbatch);

[pathRaw, fileRaw, ext] = fileparts(this.get_filename('raw'));
fileRaw = [fileRaw ext];

switch module
    
    case 'apply_transformation_field'
        % set the deformation field
        matlabbatch{1}.spm.spatial.normalise.write.subj.def = ...
            cellstr(varargin{1});
        % enter the image to be transformed
        matlabbatch{1}.spm.spatial.normalise.write.subj.resample = ...
            cellstr(spm_select('ExtFPList', pathRaw, ...
            ['^' this.parameters.save.fileName], Inf));
        % add new voxel size if defined (default is 2x2x2)
        if nargin > 3
            matlabbatch{1}.spm.spatial.normalise.write.woptions.vox ...
                = varargin{2};
        end
        
    case 'coregister_to'
        
       args = varargin{1};
        
        % set filenames for this and stationary reference image
        matlabbatch{1}.spm.spatial.coreg.estimate.ref = args.stationaryImage;
        matlabbatch{1}.spm.spatial.coreg.estimate.other = args.otherImages;
      
        matlabbatch{1}.spm.spatial.coreg.estimate.source = ...
            cellstr(spm_select('ExtFPList', pathRaw, ['^' fileRaw]));
        
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = args.objectiveFunction;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = args.separation;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = args.tolerances;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = args.histSmoothingFwhm;
        % not actually used in batch editor, but when calling spm_coreg
        % with eoptions directly;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.params = args.trafoParameters;
        matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.graphics = args.doPlot;
    case 'smooth'
        fwhmMillimeter = varargin{1};
        % load and adapt matlabbatch
        matlabbatch{1}.spm.spatial.smooth.fwhm = fwhmMillimeter;
        matlabbatch{1}.spm.spatial.smooth.data = ...
            cellstr(spm_select('ExtFPList', pathRaw, ['^' fileRaw], Inf));
        
    case 'realign'
        args = varargin{1};
        % update matlabbatch with input parameters
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = args.quality;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = args.separation;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = args.smoothingFwhm;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = args.realignToMean;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = args.interpolation;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = args.wrapping;
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = args.weighting;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = args.interpolation;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = args.wrapping;
        matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = args.masking;
        
        matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = ...
            cellstr(spm_select('ExtFPList', pathRaw, ['^' fileRaw], Inf));
        
    case 'reslice'
        fnTargetGeometry = varargin{1};
        matlabbatch{1}.spm.spatial.coreg.write.ref = ...
            cellstr(fnTargetGeometry);
        matlabbatch{1}.spm.spatial.coreg.write.source = ...
            cellstr(spm_select('ExtFPList', pathRaw, ['^' fileRaw], Inf));
        
        args = varargin{2};
        
        matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = args.interpolation;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = args.wrapping;
        matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = args.masking;
        
    case 'segment'
        tissueTypes = varargin{1};
        mapOutputSpace = varargin{2};
        deformationFieldDirection = varargin{3};
        doBiasCorrection = varargin{4};
        
        hasTPMs = nargin > 5 && ~isempty(varargin{5});
        
        hasWarpingRegularization = nargin > 6 && ~isempty(varargin{6});
        
        if hasWarpingRegularization
            warpingRegularization = varargin{6};
        else
            warpingRegularization = [0 0.001 0.5 0.05 0.2];
        end
        
        
        if ~hasTPMs
            % Take standard TPMs from spm, but update their paths...
            pathSpm = fileparts(which('spm'));
            nTissues = numel(matlabbatch{1}.spm.spatial.preproc.tissue);
            for iTissue = 1:nTissues
                matlabbatch{1}.spm.spatial.preproc.tissue(iTissue).tpm = ...
                    regexprep(matlabbatch{1}.spm.spatial.preproc.tissue(iTissue).tpm, ...
                    '/Users/kasperla/Documents/code/matlab/spm12b', ...
                    regexprep(pathSpm, '\\', '\\\\'));
            end
        else
            fileTPM = varargin{5};
            nTissues = 6;
            for iTissue = 1:nTissues
                matlabbatch{1}.spm.spatial.preproc.tissue(iTissue).tpm = ...
                    cellstr([fileTPM,',',int2str(iTissue)]);
            end
            matlabbatch{1}.spm.spatial.preproc.warp.mrf = 1;
        end
        
        % set which tissue types shall be written out and in which space
        allTissueTypes = {'GM', 'WM', 'CSF', 'bone', 'fat', 'air'};
        indOutputTissueTypes = find(ismember(lower(allTissueTypes), ...
            lower(tissueTypes)));
        for iTissueType = indOutputTissueTypes
            switch lower(mapOutputSpace)
                case 'native'
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).native = [1 0];
                case {'mni', 'standard', 'template', 'warped'}
                    matlabbatch{1}.spm.spatial.preproc.tissue(iTissueType).warped = [1 0];
            end
        end
        
        % set which deformation field shall be written out
        switch deformationFieldDirection
            case 'none'
                matlabbatch{1}.spm.spatial.preproc.warp.write = [0 0];
            case 'forward'
                matlabbatch{1}.spm.spatial.preproc.warp.write = [0 1];
            case {'backward', 'inverse'}
                matlabbatch{1}.spm.spatial.preproc.warp.write = [1 0];
            case {'both', 'all'}
                matlabbatch{1}.spm.spatial.preproc.warp.write = [1 1];
        end
        
        % set to save bias-corrected image or only bias field
        if doBiasCorrection
            matlabbatch{1}.spm.spatial.preproc.channel.write = [1 1];
        end
        
        matlabbatch{1}.spm.spatial.preproc.warp.reg = warpingRegularization;
        % set data as well
        matlabbatch{1}.spm.spatial.preproc.channel.vols = ...
            cellstr(spm_select('ExtFPList', pathRaw, ['^' fileRaw], 1));
end