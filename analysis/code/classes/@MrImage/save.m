function this = save(this, filename)
%saves image in different file formats, depending on extension
%
%   MrImage = save(MrImage)
%
% This is a method of class MrImage.
%
% IN
%   filename    possible extensions: 
%                   '.nii' - nifti
%                   '.img' - analyse, one file/scan volume
%                   '.mat' - save data and parameters separately
%                            export to matlab-users w/o class def files
%                   
% OUT
%
% EXAMPLE
%   save
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


if nargin < 2
    filename = fullfile(this.parameters.save.path, ...
        this.parameters.save.fileUnprocessed);
end

[fp, fn, ext] = fileparts(filename);

switch ext
    case '.mat'
        data = this.data;
        parameters = this.parameters;
        save(filename, 'data', 'parameters');
    case {'.nii', '.img'}
        this = save_nifti_analyze(this, filename);
end