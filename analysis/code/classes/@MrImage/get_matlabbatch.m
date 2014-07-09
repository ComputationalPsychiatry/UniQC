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
        
switch module
    case 'smooth'
        fwhmMillimeter = varargin{1};
        
        % load and adapt matlabbatch
        run(fileMatlabbatch);       
        matlabbatch{1}.spm.spatial.smooth.fwhm = fwhmMillimeter;
        matlabbatch{1}.spm.spatial.smooth.data = ...
            cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], Inf));
    case 'realign'
        quality = varargin{1};
                % load and adapt matlabbatch
        run(fileMatlabbatch);   
        matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = ...
            quality;
        matlabbatch{1}.spm.spatial.realign.estwrite.data{1} = ...
             cellstr(spm_select('ExtFPList', this.parameters.save.path, ...
            ['^' this.parameters.save.fileUnprocessed], Inf));
end