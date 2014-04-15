function load_nifti_analyze(objectMrImage, fileName);
% loads matrix into .data from nifti or analyze file using spm_read_vols 
%
%   load_nifti_analyze(objectMrImage, fileName);
%
% IN
%
% OUT
%
% EXAMPLE
%   load_nifti_analyze
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-04-16
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Analysis Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: new_function2.m 354 2013-12-02 22:21:41Z kasperla $

objectMrImage.data = rand(128,128,36);
%[~, objectMrImage.data] = spm_img_load(fileName);