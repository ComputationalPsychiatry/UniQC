function [tissueProbMaps, deformationFields] = ...
    segment(this, tissueTypeArray, imageOutputSpace, ...
    deformationFieldDirection)
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
%   Y.segment(tissueTypeArray, imageOutputSpace, deformationFieldDirection)
%
% This is a method of class MrImage.
%
% IN
%   tissueTypeArray     cell(nTissues, 1) of strings to specify which 
%                       tissue types shall be written out:
%                       'GM'    grey matter
%                       'WM'    white matter
%                       'CSF'   cerebrospinal fluid
%                       'fat'   fat and muscle tissue
%                       'bone'  skull and surrounding bones
%                       'air'   air surrounding head
%                       
%                       default: {'GM', 'WM', 'CSF'}
%                       
%   imageOutputSpace    'native' (default), 'warped'/'mni'/'standard' or
%                       'both'
%                       defines coordinate system in which images shall be
%                       written out; 
%                       'native' same space as image that was segmented
%                       'warped' standard Montreal Neurological Institute
%                                (MNI) space used by SPM for unified segmentation
%                       'both'   native and standard space images are both 
%                                written out 
%  deformationFieldDirection determines which deformation field shall be
%                       written out,if any
%                       'none' (default) no deformation fields are stored
%                       'forward' subject => mni (standard) space
%                       'backward'/'inverse' mni => subject space
%                       'both'  = 'forward' and 'backward'
%   
% OUT
%   tissueProbMaps      cell(nTissues, nOutputSpaces) of MrImages
%                       containing the tissue probability maps in the
%                       respective order in rows, 
%                       if both coordinate sytems are selected for output
%                       1st column = native space; 2nd column: MNI-space
%   deformationFields   cell(nDeformationFieldDirections,1)
%                       if deformationFieldDirection is 'both', this cell
%                       contains the forward deformation field in the first
%                       entry, and the backward deformation field in the
%                       second cell entry; otherwise, a cell with only one
%                       element is returned
% EXAMPLE
%   segment
%
%   See also MrImage
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-08
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

% save image file for processing as nii in SPM
this.save();

if nargin < 2
    tissueTypeArray = {'WM', 'GM', 'CSF'};
end

if nargin < 3
    imageOutputSpace = 'native';
end

if nargin < 4
    deformationFieldDirection = 'none';
end

matlabbatch = this.get_matlabbatch('segment', tissueTypeArray, ...
    imageOutputSpace, deformationFieldDirection);
save(fullfile(this.parameters.save.path, 'matlabbatch.mat'), ...
            'matlabbatch');
spm_jobman('run', matlabbatch);

% clean up: move/delete processed spm files, load new data into matrix

tissueProbMaps.finish_processing_step('segment');