function this = read_dicom(this, fileName)
% loads matrix into .data from DICOM file using dicomdir Matlab
%
%   this = read_dicom(this, fileName)
%
% IN
%   fileName
%
% OUT
%
% EXAMPLE
%   Y = MrDataNd();
%   Y.read_dicom('test.ima')
%   Y.read_dicom('test.ima')
%
%   See also

% Author:   Lars Kasper
% Created:  2021-10-27
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.


if nargin < 2
    fileName = fullfile(this.parameters.path, ...
        this.parameters.unprocessedFile);
end

X = tapas_uniqc_dicom_mosaic2image(fileName);
this.data = X.data;