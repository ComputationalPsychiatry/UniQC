function this = load(this, fileName)
% loads object from struct in .mat-file, from variable named 'objectAsStruct'
%
%
%   Y = MrCopyData()
%   Y.load(inputs)
%
% This is a method of class MrCopyData.
%
% IN
%
% OUT
%
% EXAMPLE
%   load
%
%   See also MrCopyData MrCopyData.save MrCopyData.update_properties_from
%
% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-08-14
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3. 
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

load(fileName, 'objectAsStruct');

this.update_properties_from(objectAsStruct);