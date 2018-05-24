function [this, realignmentParameters] = realign(this, quality)
% Realigns all 3D images in 4D data to each other, then to the mean
% Uses SPM's realign: estimate+rewrite functionality
%
%   Y = MrImage()
%   Y.realign(quality)
%
% This is a method of class MrImage.
%
% IN
%   quality         0...1 quality of realignment (0 = worst, 1 = best)
%                   defaut: 0.9
% OUT
%
% EXAMPLE
%   realign
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

if nargin < 2
    quality = 0.9;
end

% save image file for processing as nii in SPM
% for complex-valued images, realign absolute value of image
if ~isreal(this)
    % TODO: next lines as...
    % [this, otherImage] = this.split_complex('abs');
    this.abs.save(this.get_filename('raw'));
    otherImage = angle(this);
    otherImage.save.fileName = otherImage.get_filename('phase');
    otherImage.save(otherImage.get_filename('raw'));
    
else
    this.save('fileName', this.get_filename('raw'));
	otherImage = {};
end

matlabbatch = this.get_matlabbatch('realign', quality, otherImage);


save(fullfile(this.parameters.save.path, 'matlabbatch.mat'), ...
            'matlabbatch');
spm_jobman('run', matlabbatch);

% clean up: move/delete processed spm files, load new data into matrix

realignmentParameters = this.finish_processing_step('realign');
