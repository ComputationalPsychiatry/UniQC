function this = init_processing_step(this, module)
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

this.data.parameters.save.keepCreatedFiles = 1; % keeps files
this.data.parameters.save.fileUnprocessed = 'raw.nii';
this.data.parameters.save.fileProcessed = 'processed.nii';
pathSaveRoot = fullfile(this.parameters.save.path, this.name);

% save initial, unprocessed data
isFirstProcessingStep = ~this.nProcessingSteps;
if isFirstProcessingStep
    dirProcessing = sprintf('%03d_%s', this.nProcessingSteps, 'unprocessed');
    pathProcessing = fullfile(pathSaveRoot, dirProcessing);
    mkdir(pathProcessing);
    this.data.parameters.save.path = pathProcessing;
    this.data.save(); % rather: this.save and strip data!
end

% specify new directory to save data here
this.nProcessingSteps = this.nProcessingSteps + 1;
dirProcessing = sprintf('%03d_%s', this.nProcessingSteps, module);
pathProcessing = fullfile(pathSaveRoot, dirProcessing);

this.data.parameters.save.path = pathProcessing;

mkdir(pathProcessing);
this.processing_log{end+1} = dirProcessing;


% module-specific adaptations, e.g. data copying

switch module
    case 'realign'
    case 'smooth'
    
        % set file names and save path for statistical images
    case 'compute_stat_images' 
        statImageArray = {'mean', 'sd', 'snr', 'coeffVar', 'diffLastFirst'};
        nStatImages = numel(statImageArray);
        for k = 1:nStatImages
            img = statImageArray{k};
            this.(img).parameters.save.path = pathProcessing;
            this.(img).parameters.save.fileUnprocessed = [img '.nii'];
        end
end
        
end