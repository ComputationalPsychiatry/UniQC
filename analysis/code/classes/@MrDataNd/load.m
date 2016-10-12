function this = load(this, inputDataOrFile, varargin)
% loads (meta-)data from file(s), order defined by loopDimensions
%
%   Y = MrDataNd()
%   Y.load(varargin)
%
% This is a method of class MrDataNd.
%
% IN
%   inputDataOrFile     can be one of three inputs
%                       1) a Matrix: MrDataNd is created along with a
%                          dimInfo matching the dimensions of the data
%                          matrix
%                       b) a file-name: MrDataNd is loaded from the
%                          specified file
% OUT
%
% EXAMPLE
%   load
%
%   See also MrDataNd
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2016-05-25
% Copyright (C) 2016 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$

if nargin < 2
    inputDataOrFile = this.get_filename();
end
defaults.selection = [];

args = propval(varargin, defaults);
strip_fields(args);

isMatrix = isnumeric(inputDataOrFile) || islogical(inputDataOrFile);

if isMatrix
    inputData = inputDataOrFile;
end