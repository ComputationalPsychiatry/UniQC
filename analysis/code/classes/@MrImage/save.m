function filename = save(this, filename, dataType)
%saves image in different file formats, depending on extension
%
%   Y = MrImage();
%   filename = Y.save(filename)
%
% This is a method of class MrImage.
%
% IN
%   filename    possible extensions:
%                   '.nii' - nifti
%                   '.img' - analyse, one file/scan volume
%                   '.mat' - save data and parameters separately
%                            export to matlab-users w/o class def files
%               default: parameters.save.path/parameters.save.fileUnprocessed
%               can be set via parameters.save.path.whichFilename = 0 to
%               parameters.save.path/parameters.save.fileName
%   dataType    number format for saving voxel values; see also spm_type
%               specified as one of the following string identifiers
%                'uint8','int16','int32','single','double','int8','uint16','uint32';
%               default (3D): single
%               default (4D or size > 30 MB): int32
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
    filename = this.get_filename;
end

if nargin < 3
    dataType = get_data_type_from_n_voxels(this.geometry.nVoxels);
end

% no data, no saving...
if isempty(this.data)
    fprintf('No data in MrImage %s; file %s not saved\n', this.name, ...
        filename);
    
else
    
    [fp, fn, ext] = fileparts(filename);
    
    if ~isempty(fp)
        [s, mess, messid] = mkdir(fp); % to suppress dir exists warning
    end
    
    switch ext
        case '.mat'
            
            % conversion to compact file format, different naming
            % conventions spm/matlab types
            switch dataType
                case 'float32'
                    dataType = 'single';
                case 'float64'
                    dataType = 'double';
            end
            
            data = cast(this.data, dataType);
            
            parameters = this.parameters;
            geometry = this.geometry;
            save(filename, 'data', 'parameters', 'geometry');
        case {'.nii', '.img', '.hdr'}
            this = save_nifti_analyze(this, filename, dataType);
        otherwise
            error('Unknown file extension');
    end
end
