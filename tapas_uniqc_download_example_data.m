function tapas_uniqc_download_example_data(exampleIDs, dataRoot, doOverwrite)
% TAPAS_UNIQC_DOWNLOAD_EXAMPLE_DATA
%
% Central wrapper to download UniQC example datasets. 
%   Downloaded data found in data/ subfolder
%   Code for using example data found in demo/ subfolder
%
% Usage:
%   tapas_uniqc_download_example_data
%   tapas_uniqc_download_example_data("info")
%   tapas_uniqc_download_example_data("openneuro_ds004662")
%   tapas_uniqc_download_example_data(["openneuro_ds004662","other_dataset"])
%
% Inputs:
%   exampleIDs  : dataset(s) to download, or "info"
%   dataRoot    : root folder (default: <UniQC_root>/data)
%   doOverwrite : logical flag (default: false)

%% ------------------------------------------------------------------------
%  Dataset registry
% -------------------------------------------------------------------------
registry = availableDatasets();

%% ------------------------------------------------------------------------
%  Handle INFO mode
% -------------------------------------------------------------------------
if nargin >= 1 && ~isempty(exampleIDs)
    if any(strcmpi(string(exampleIDs), ["info","-info","--info"]))
        printAvailableDatasets(registry);
        return
    end
end

%% ------------------------------------------------------------------------
%  Defaults
% -------------------------------------------------------------------------
if nargin < 1 || isempty(exampleIDs)
    exampleIDs = registry.ids;
end

if nargin < 2 || isempty(dataRoot)
    thisFile = mfilename('fullpath');
    uniqcRoot = fileparts(thisFile);
    dataRoot = fullfile(uniqcRoot, 'data');
end

if nargin < 3 || isempty(doOverwrite)
    doOverwrite = false;
end

if ischar(exampleIDs)
    exampleIDs = string(exampleIDs);
end

if ~exist(dataRoot,'dir')
    mkdir(dataRoot);
end

fprintf('\n=== UniQC Example Data Downloader ===\n');
fprintf('Target directory: %s\n', dataRoot);
fprintf('Overwrite existing: %d\n\n', doOverwrite);

%% ------------------------------------------------------------------------
%  Dispatch
% -------------------------------------------------------------------------
for i = 1:numel(exampleIDs)

    id = lower(string(exampleIDs(i)));

    idx = find(strcmpi(registry.ids, id),1);
    if isempty(idx)
        error('Unknown example dataset: %s\nUse "info" to list available datasets.', id);
    end

    fprintf('Downloading: %s\n', id);

    switch id

        case "openneuro_ds004662"

            dest = fullfile(dataRoot, 'openneuro', 'ds004662');
            tapas_uniqc_download_example_data_openneuro_ds004662(dest, doOverwrite);

        % --- Future datasets here ---

    end

    fprintf('\n');
end

fprintf('=== Done ===\n\n');

end

%% ========================================================================
function registry = availableDatasets()

registry.ids = [
    "openneuro_ds004662"
];

registry.description = [
    "OpenNeuro ds004662 (v1.1.0) – multi-echo fMRI example with varying motion levels"
];

end

%% ========================================================================
function printAvailableDatasets(registry)

fprintf('\n=== Available UniQC Example Datasets ===\n\n');

for i = 1:numel(registry.ids)
    fprintf('  %-25s  %s\n', registry.ids(i), registry.description(i));
end

fprintf('\nUse:\n');
fprintf('  tapas_uniqc_download_example_data("<dataset_id>")\n\n');

end