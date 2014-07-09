classdef MrGlm < CopyData
% Class providing General Linear Model of fMRI data
% (for mass-univariate analysis, i.e. per-voxel regression)
%
%
% EXAMPLE
%   MrGlm
%
%   See also
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

properties
    
 % Multiple regressors, i.e. confounds that will be regressed directly,
 % without convolution with the hemodynamic response function(s).
 % fields:
 %      realign     Realignment parameters
 regressors = struct( ...
     'realign', [], ...
     'physio', [], ...
     'other', [] ...
 );
 
 % Multiple conditions, i.e. behavioral/neuronal regressors that will be 
 % convolved with the hemodynamic response function(s).
 conditions = struct( ...
     'basic', [], ...
     'parametric', [], ...
     'other', [] ...
 );
 
 % The final design matrix used for the voxel-wise regression
 designMatrix = [];
 
end % properties
 
 
methods

% Constructor of class
function this = MrGlm()
end

% NOTE: Most of the methods are saved in separate function.m-files in this folder;
%       except: constructor, delete, set/get methods for properties.

end % methods
 
end
