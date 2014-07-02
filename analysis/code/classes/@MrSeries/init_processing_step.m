function this = init_processing_step(this)
% initializes next processing step by creating folders for version tracking, 
% shuffling data, and updating processing parameters
%
%   MrSeries = init_processing_step(MrSeries, module)
%
% This is a method of class MrSeries.
%
% IN
%   module      'realign', 'smooth', ...
%
% OUT
%
%   side effects:
%   new folder (with current data):
%       dirObject/<nProcessingSteps+1>_moduleName
%   parameters.processing_log
%   nProcessingSteps
%
% EXAMPLE
%   init_processing_step
%
%   See also MrSeries
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
% $Id$

this.nProcessingSteps = this.nProcessingSteps + 1;
dirProcessing = sprintf('%03d_%s', this.nProcessingSteps, module);
pathProcessing = fullfile(this.parameters.path, this.name, dirProcessing);

mkdir(pathProcessing);
this.processing_log{end+1} = dirProcessing;


% module-specific adaptations, e.g. data copying

switch module
    case 'realign'
        %copy data to new folder ... check whether it exists
end
        
end