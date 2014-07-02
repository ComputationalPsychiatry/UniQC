classdef MrRoi < CopyData
%class for regions of interest of an MrImage OR MrSeries
%
%
% EXAMPLE
%   MrRoi
%
%   See also MrImage MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-01
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
% $Id: new_class2.m 354 2013-12-02 22:21:41Z kasperla $

properties
 % COMMENT_BEFORE_PROPERTY
 data       % {Sli,1} cell of [nVoxelSli,nScans] matrices for 4D data
            %  {Sli,1} cell of [nVoxelSli,1] voxel values
 name       % string (e.g. name of mask and data input combined)
end % properties
 
 
methods

% Constructor of class
function this = MrRoi(data, mask)
end

% NOTE: Most of the methods are saved in separate function.m-files in this folder;
%       except: constructor, delete, set/get methods for properties.

% computes mean, sd and snr for each region/slice and pooled over all
% voxels in the region
function compute_stats()
end
end % methods
 
end
