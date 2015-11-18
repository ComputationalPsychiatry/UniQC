function this = restore(this, iProcessingStep, loadData)
% Restores status+data of MrSeries for a given previous processing step
%
%   Y = MrSeries()
%   Y.restore(iProcessingStep)
%
% This is a method of class MrSeries.
%
% IN
%   iProcessingStep     index of processing step to be restored
%                       0               - raw data
%                       Inf or 'last'   - fully processed data (default)
%   loadData            1               - load MrSeries object and dress
%                                         with data (default)
%                       0               - load only MrSeries object (no data) 
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

pathSave = this.parameters.save.path;
if nargin < 2
    iProcessingStep = Inf;
end

if ischar(iProcessingStep);
    switch iProcessingStep
        case 'last'
            iProcessingStep = Inf;
    end
end

% after call to MrObject.save, data is stored directly in MrSeries-path,
% load it from there
if exist(fullfile(pathSave, 'MrObject.mat'), 'file')
    dirProcessing = '';
    iProcessingStep = -1;
end

% MrObject in old state is saved in subfolder with processingLog name
switch iProcessingStep
    case -1
    case 0
        dirProcessing = sprintf('%03d_%s', 0, 'unprocessed');
    case num2cell(1:this.nProcessingSteps) % saved processing steps in object
        dirProcessing = this.processingLog{iProcessingStep};
    case Inf
        [~, dirProcessing] = this.find_max_processing_step();
    otherwise % existing processing steps that are unknown to the object at runtime
        dirProcessing =  dir(fullfile(pathSave, ...
            sprintf('%03d_*',iProcessingStep)));
        dirProcessing = dirProcessing.name;
end


filenameMrObject = fullfile(this.parameters.save.path, dirProcessing, ...
    'MrObject.mat');

load(filenameMrObject, 'MrObject');
% this = MrObject.copyobj;...does not work...
% so: update via overwriting everything, including empty values
this.update_properties_from(MrObject, 2)

% check whether only the object is needed
if nargin < 3
    loadData = 1;
end

% dress MrSeries with all the data saved separately
if loadData    
    handleImageArray = this.find('MrImage');
    for iImage = 1:numel(handleImageArray);
        handleImageArray{iImage}.load([], 'updateProperties', 'none');
    end
    
    
    handleRoiArray = this.find('MrRoi');
    for iRoi = 1:numel(handleRoiArray);
        handleRoiArray{iRoi}.load_data;
    end
    
end

end

%
% [~, nameImageArray] = this.get_all_image_objects();
% for iImage = 1:numel(nameImageArray);
%     this.(nameImageArray{iImage}).load([], 'updateProperties', 'none');
% end
