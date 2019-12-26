function [biasFieldCorrected, varargout] = segment(this, varargin)
% Segments brain images using SPM's unified segmentation approach.
% This warps the brain into a standard space and segment it there using tissue
% probability maps in this standard space.
%
% Since good warping and good segmentation are interdependent, this is done
% iteratively until a good tissue segmentation is given by probality maps
% that store how likely a voxel is of a certain tissue type
% (either in native or standard space).
% Furthermore, a deformation field from native to standard space (or back)
% has then been found for warping other images of the same native space.
%
%   Y = MrImage()
%   [biasFieldCorrected, tissueProbMaps, deformationFields, biasField] = ...
%   Y.segment(...
%       'representationIndexArray', representationIndexArray, ...
%       'spmParameterName1', spmParameterValue1, ...
%       ...
%       'spmParameterNameN', spmParameterValueN)
%
% This is a method of class MrImageSpm4D.
%
% NOTE: If an nD image is given, then all dimension > 3  will be treated as
% channels.
%
% IN
%   tissueTypes         cell(1, nTissues) of strings to specify which
%                       tissue types shall be written out:
%                       'GM'    grey matter
%                       'WM'    white matter
%                       'CSF'   cerebrospinal fluid
%                       'bone'  skull and surrounding bones
%                       'fat'   fat and muscle tissue
%                       'air'   air surrounding head
%
%                       default: {'GM', 'WM', 'CSF'}
%
%   mapOutputSpace      'native' (default), 'warped'/'mni'/'standard' or
%                       'both'
%                       defines coordinate system in which images shall be
%                       written out;
%                       'native' same space as image that was segmented
%                       'warped' standard Montreal Neurological Institute
%                                (MNI) space used by SPM for unified segmentation
%  deformationFieldDirection determines which deformation field shall be
%                       written out,if any
%                       'none' (default) no deformation fields are stored
%                       'forward' subject => mni (standard) space
%                       'backward'/'inverse' mni => subject space
%                       'both'/'all' = 'forward' and 'backward'
%  saveBiasField        0 (default) or 1
%  biasRegularisation   describes the amount of expected bias field
%                       default: 0.001 (light)
%                       no: 0; extremely heavy: 10
%  biasFWHM             full-width-at-half-maximum of the Gaussian
%                       non-uniformity bias field (in mm)
%                       default: 60 (mm)
%  fileTPM              tissue probablity maps for each tissue class
%                       default: SPM' TPMs in spm/tpm
%  mrfParameter         strenght of the Markov Random Field cleanup
%                       performed on the tissue class images
%                       default: 1
%  cleanUp              crude routine for extracting the brain from
%                       segmented images ('no', 'light', 'thorough')
%                       default: 'light'
%  warpingRegularization regularization for the different terms of the
%                       registration
%                       default: [0 0.001 0.5 0.05 0.2]
%  affineRegularisation regularisation for the initial affine registration
%                       of the image to the tissue probability maps (i.e.
%                       into standard space)
%                       for example, the default ICBM template are slighlty
%                       larger than typical brains, so greater zooms are
%                       likely to be needed
%                       default: ICBM spase template - European brains
%  smoothnessFwhm       fudge factor to account for correlation between
%                       neighbouring voxels (in mm)
%                       default: 0 (for MRI)
%  samplingDistance     approximate distance between sampled points when
%                       estimating the model parameters (in mm)
%                       default: 3
%
%   Parameters for high-dim application:
%
%   representationIndexArray:   either an MrImageObject or a selection
%                               (e.g. {'echo', 1} which is then applied to
%                               obtain one 4D image
%                               default representationIndexArray: first
%                               index of all extra (non-4D) dimensions
%   applicationIndexArray:      a selection which defines one or multiple
%                               4D images on which the estimated parameters
%                               are applied
%                               default applicationIndexArray: all non-4D
%                               dimensions
%   splitComplex                'ri' or 'mp'
%                               If the data are complex numbers, real and
%                               imaginary or magnitude and phase are
%                               realigned separately.
%                               default: mp (magnitude and p)
%                               Typically, realigning the magnitude and
%                               applying it to the phase data makes most
%                               sense; otherwise, using real and imaginary
%                               part, more global phase changes would
%                               impact on estimation
%
% OUT
%   biasCorrected       bias corrected images
%   tissueProbMaps      (optional) cell(nTissues,1) of 3D MrImages
%                       containing the tissue probability maps in the
%                       respective order as volumes,
%   deformationFields   (optional) cell(nDeformationFieldDirections,1)
%                       if deformationFieldDirection is 'both', this cell
%                       contains the forward deformation field in the first
%                       entry, and the backward deformation field in the
%                       second cell entry; otherwise, a cell with only one
%                       element is returned
%   biasField           (optional) bias field
%
% EXAMPLE
% [biasFieldCorrected, tissueProbMaps, deformationFields, biasField] =
%   Y.segment();
%
% for 7T images stronger non-uniformity expected
% [biasFieldCorrected, tissueProbMaps, deformationFields, biasField] = ...
%   m.segment('biasRegularisation', 1e-4, 'biasFWHM', 18, ...
%   'cleanUp', 2, 'samplingDistance', 2);
%
%   See also MrImage spm_preproc MrImageSpm4D.segment
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2019-12-23
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

% spm parameters (details above)
spmDefaults.tissueTypes = {'WM', 'GM', 'CSF'};
spmDefaults.mapOutputSpace = 'native';
spmDefaults.deformationFieldDirection = 'none';
spmDefaults.saveBiasField = 0;
spmDefaults.biasRegularisation = 0.001;
spmDefaults.biasFWHM = 60;
spmDefaults.fileTPM = [];
spmDefaults.mrfParameter = 1;
spmDefaults.cleanUp = 'light';
spmDefaults.warpingRegularization = [0 0.001 0.5 0.05 0.2];
spmDefaults.affineRegularisation = 'mni';
spmDefaults.smoothnessFwhm = 0;
spmDefaults.samplingDistance = 3;

[spmParameters, unusedVarargin] = propval(varargin, spmDefaults);

% for split/apply functionality
methodParameters = {spmParameters};

% use cases: abs of complex, single index on many!
defaults.representationIndexArray   = {}; % default: use all
defaults.splitDimLabels             = {};
defaults.splitComplex               = 'mp';

args = propval(unusedVarargin, defaults);
strip_fields(args);

% check whether real/complex
isReal = isreal(this);

if isReal
    inputSegment = this.copyobj();
else
    inputSegment = this.split_complex(splitComplex);
end
% Merge all n>3 dims, which are not part of the representationIndexArray, into 4D array
dimLabelsSpm3D = {'x','y','z'};
mergeDimLabels = setdiff(inputSegment.dimInfo.dimLabels, dimLabelsSpm3D);
% additional channels need to be in the t dimensions so they become part of
% the same nifti file
% empty mergeDimLabels just return the original object, e.g. for true 3D
% images
[mergedImage, newDimLabel] = ...
    inputSegment.merge(mergeDimLabels, 'dimLabels', 't');

% prepare output container with right size
varargout = cell(1,nargout-1);
if nargout > 1
    [biasFieldCorrected, varargout{:}] = ...
        mergedImage.apply_spm_method_per_4d_split(@segment, ...
        'methodParameters', methodParameters);
else
    biasFieldCorrected = mergedImage.apply_spm_method_per_4d_split(@segment, ...
        'methodParameters', methodParameters);
end

% un-do merge operation using combine
if ~isempty(mergeDimLabels)
    % not necessary for 4D images - just reset dimInfo
    if numel(mergeDimLabels) == 1
        origDimInfo = inputSegment.dimInfo;
        biasFieldCorrected.dimInfo = origDimInfo;
    else
        % created original dimInfo per split
        origDimInfo = this.dimInfo.split(mergeDimLabels);
        % un-do reshape
        split_array = biasFieldCorrected.split('splitDims', newDimLabel);
        split_array = reshape(split_array, size(origDimInfo));
        % add origal dimInfo
        for nSplits = 1:numel(split_array)
            split_array{nSplits}.dimInfo = origDimInfo{nSplits};
        end
        % combine
        biasFieldCorrected = split_array{1}.combine(split_array);
    end
end

if ~isReal
    % un-do complex split
    biasFieldCorrected = biasFieldCorrected.combine_complex();
end
end


