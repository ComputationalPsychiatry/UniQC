function this = restore(this, iProcessingStep)
% Restores status+data of MrSeries for a given previous processing step
%
%   Y = MrSeries()
%   Y.restore(iProcessingStep)
%
% This is a method of class MrSeries.
%
% IN
%   iProcessingStep         index of processing step to be restored
%                           0               - raw data
%                           Inf or 'last'   - fully processed data (default)
%
% OUT
%
% EXAMPLE
%   restore
%
%   See also MrSeries
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-07-09
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
    iProcessingStep = Inf;
end

if ischar(iProcessingStep);
    switch iProcessingStep
        case 'last'
            iProcessingStep = Inf;
    end
end

if isinf(iProcessingStep)
    iProcessingStep = this.nProcessingSteps;
end


% MrObject in old state is saved in subfolder with processing_log name
switch iProcessingStep
    case 0
        dirProcessing = sprintf('%03d_%s', 0, 'unprocessed');
        
    otherwise
        dirProcessing = this.processing_log{iProcessingStep};
end
filenameMrObject = fullfile(this.parameters.save.path, dirProcessing, ...
    'MrObject.mat');

load(filenameMrObject, 'MrObject');
this = MrObject;

% dress MrSeries with all the data saved separately
[~, nameImageArray] = this.get_all_image_objects();
for iImage = 1:numel(nameImageArray);
    this.(nameImageArray{iImage}).load;
end
