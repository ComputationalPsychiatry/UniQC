function tapas_uniqc_download_example_data_openneuro_ds004662(destRoot, doOverwrite)
% tapas_uniqc_download_example_data_openneuro_ds004662(destRoot)
%
% Downloads a small, reproducible subset of OpenNeuro ds004662 (snapshot 1.1.0)
% for UniQC examples, using only MATLAB web access (no datalad/git-annex/jq).
%
% Subset:
%   sub-03 run-1 (low motion)
%   sub-04 run-1 (moderate motion)
%   sub-08 run-2 (high motion)
%   sub-01 run-2 (very high motion)
%
% Output (BIDS-preserved) under:
%   destRoot/sub-XX/func/<files>
%   destRoot/derivatives/{handgrasp_regressors,CO2_regressors}/sub-XX/<files>
%
% Example:
%   tapas_uniqc_download_example_data_openneuro_ds004662(fullfile(pwd,'examples','openneuro','ds004662'));

if nargin < 1 || isempty(destRoot)
    destRoot = tapas_uniqc_get_path_data('openneuro_ds004662');
end

if nargin < 2
    doOverwrite = false;
end

if doOverwrite
    if exist(destRoot, 'dir')
        rmdir(destRoot, 's');
    end
end

if ~exist(destRoot, 'dir'); mkdir(destRoot); end

datasetId   = "ds004662";
snapshotTag = "1.1.0";
task        = "handgrasp";

% OpenNeuro GraphQL endpoint
graphqlUrl = "https://openneuro.org/crn/graphql";

% Requested (subject, run) pairs
pairs = {
    "sub-03", 1
    "sub-04", 1
    "sub-08", 2
    "sub-01", 2
};

% --- GraphQL helpers -----------------------------------------------------
baseOpts = weboptions("MediaType", "application/json", "Timeout", 120);

    function response = gql_request(query)
        try
            % webwrite sends MATLAB structs as JSON objects when MediaType
            % is application/json, which matches OpenNeuro's GraphQL API.
            response = webwrite(graphqlUrl, struct("query", query), baseOpts);
        catch ME
            fprintf('\nHTTP request failed during send.\n');
            rethrow(ME);
        end
        if isfield(response, 'errors') && ~isempty(response.errors)
            fprintf('\n--- GraphQL Query Errors ---\n');
            disp(response.errors);
            fprintf('----------------------------\n');
            error('GraphQL query failed. See server response above.');
        end
    end
gql = @gql_request;

    function files = listTree(treeId)
        if nargin < 1 || strlength(treeId)==0
            q = sprintf(['query { snapshot(datasetId: "%s", tag: "%s") { ' ...
                         'files { filename directory id urls size } } }'], datasetId, snapshotTag);
        else
            q = sprintf(['query { snapshot(datasetId: "%s", tag: "%s") { ' ...
                         'files(tree: "%s") { filename directory id urls size } } }'], datasetId, snapshotTag, treeId);
        end
        r = gql(q);
        if ~isfield(r, 'data') || ~isfield(r.data,'snapshot') || ~isfield(r.data.snapshot,'files')
            error("OpenNeuro API response did not include expected fields.");
        end
        files = r.data.snapshot.files;
    end

    function dirId = findDirId(parentTreeId, dirname)
        f = listTree(parentTreeId);
        dirId = "";
        for i = 1:numel(f)
            if isfield(f(i), 'directory') && f(i).directory && string(f(i).filename) == dirname
                dirId = string(f(i).id);
                return
            end
        end
    end

    function [url, found] = findFileUrl(treeId, filename)
        f = listTree(treeId);
        url = "";
        found = false;
        for i = 1:numel(f)
            if ~f(i).directory && string(f(i).filename) == filename
                found = true;
                if isfield(f(i), 'urls') && ~isempty(f(i).urls)
                    u = f(i).urls;
                    if iscell(u), url = string(u{1}); else, url = string(u(1)); end
                end
                return
            end
        end
    end

    function downloadOne(treeId, filename, relPath)
        outFile = fullfile(destRoot, relPath);
        if exist(outFile, 'file')
            fprintf("[ok] exists: %s\n", relPath);
            return
        end

        [url, found] = findFileUrl(treeId, filename);
        if ~found
            error("File not found in snapshot tree: %s", filename);
        end
        if strlength(url)==0
            error("No download URL returned for: %s", filename);
        end

        outDir = fileparts(outFile);
        if ~exist(outDir, 'dir'); mkdir(outDir); end

        fprintf("[download] %s\n", relPath);
        websave(outFile, url, weboptions("Timeout", 120)); %#ok<WEBSAVE>
    end

    function downloadT1wAnat(subDirId, sub)
        % Download anatomical T1w NIfTI + JSON for a given subject.
        % Common BIDS layout: sub-XX/anat/*_T1w.(nii.gz|json)
        % (If the dataset uses sessions, you can extend this similarly for ses-*/anat.)

        anatDirId = findDirId(subDirId, "anat");
        if strlength(anatDirId)==0
            fprintf("(i) No anat directory for %s (skipping T1w)\n", sub);
            return
        end

        fAnat = listTree(anatDirId);
        fnAnat = string({fAnat.filename});
        isFile = ~[fAnat.directory];
        filesOnly = fnAnat(isFile);

        t1nii  = filesOnly(endsWith(filesOnly, "_T1w.nii.gz"));
        t1json = filesOnly(endsWith(filesOnly, "_T1w.json"));

        if isempty(t1nii) && isempty(t1json)
            fprintf("(i) No T1w files found in %s/anat (skipping)\n", sub);
            return
        end

        for k = 1:numel(t1nii)
            file = t1nii(k);
            downloadOne(anatDirId, file, fullfile(sub, "anat", file));
        end
        for k = 1:numel(t1json)
            file = t1json(k);
            downloadOne(anatDirId, file, fullfile(sub, "anat", file));
        end
    end

    function downloadRegressors(derivativesDirId, sub, run)
        % Download the published, HRF-convolved handgrasp and CO2 regressors.
        regressorFolders = ["handgrasp_regressors", "CO2_regressors"];
        regressorFilenames = string({ ...
            sprintf("%s_task-%s_run-%d_desc-righthandgrasp_regressor.txt", ...
            sub, task, run), ...
            sprintf("%s_task-%s_run-%d_desc-lefthandgrasp_regressor.txt", ...
            sub, task, run), ...
            sprintf("%s_task-%s_run-%d_desc-CO2_regressor.txt", ...
            sub, task, run)});
        filenameFolderIndices = [1, 1, 2];

        for iFile = 1:numel(regressorFilenames)
            folder = regressorFolders(filenameFolderIndices(iFile));
            folderDirId = findDirId(derivativesDirId, folder);
            if strlength(folderDirId) == 0
                error("Could not find derivative directory: %s", folder);
            end
            subjectDirId = findDirId(folderDirId, sub);
            if strlength(subjectDirId) == 0
                error("Could not find %s/%s", folder, sub);
            end
            filename = regressorFilenames(iFile);
            downloadOne(subjectDirId, filename, ...
                fullfile("derivatives", folder, sub, filename));
        end
    end

% --- Optional: dataset-level metadata ------------------------------------
% Download dataset_description.json if present at root (nice for provenance)
try
    rootFiles = listTree("");
    hasDD = any(arrayfun(@(x) ~x.directory && string(x.filename)=="dataset_description.json", rootFiles));
    if hasDD
        downloadOne("", "dataset_description.json", "dataset_description.json");
    end
catch
    % non-fatal
end

derivativesDirId = findDirId("", "derivatives");
if strlength(derivativesDirId) == 0
    error("Could not find derivatives directory at dataset root.");
end

% --- Main download loop --------------------------------------------------
for p = 1:size(pairs,1)
    sub = string(pairs{p,1});
    run = pairs{p,2};

    fprintf("\n=== %s run-%d ===\n", sub, run);

    subDirId = findDirId("", sub);
    if strlength(subDirId)==0
        error("Could not find subject directory at root: %s", sub);
    end

    % Anatomical T1w (if present)
    downloadT1wAnat(subDirId, sub);

    % Published, HRF-convolved physiology regressors
    downloadRegressors(derivativesDirId, sub, run);

    funcDirId = findDirId(subDirId, "func");
    if strlength(funcDirId)==0
        error("Could not find func directory for %s", sub);
    end

    % List func files once, then select what we need
    f = listTree(funcDirId);
    fn = string({f.filename});

    % Events (if present)
    % Try to find events file with run-id, then fallback to without.
    ev_with_run = sprintf("%s_task-%s_run-%d_events.tsv", sub, task, run);
    ev_without_run = sprintf("%s_task-%s_events.tsv", sub, task);
    if any(fn == ev_with_run)
        downloadOne(funcDirId, ev_with_run, fullfile(sub, "func", ev_with_run));
    elseif any(fn == ev_without_run)
        downloadOne(funcDirId, ev_without_run, fullfile(sub, "func", ev_without_run));
    end

    % Physio (if present)
    % Try to find physio file with run-id, then fallback to without.
    phys_tsv_with_run = sprintf("%s_task-%s_run-%d_physio.tsv.gz", sub, task, run);
    phys_json_with_run = sprintf("%s_task-%s_run-%d_physio.json", sub, task, run);
    phys_tsv_without_run = sprintf("%s_task-%s_physio.tsv.gz", sub, task);
    phys_json_without_run = sprintf("%s_task-%s_physio.json", sub, task);
    if any(fn == phys_tsv_with_run)
        downloadOne(funcDirId, phys_tsv_with_run, fullfile(sub, "func", phys_tsv_with_run));
    elseif any(fn == phys_tsv_without_run)
        downloadOne(funcDirId, phys_tsv_without_run, fullfile(sub, "func", phys_tsv_without_run));
    end
    if any(fn == phys_json_with_run)
        downloadOne(funcDirId, phys_json_with_run, fullfile(sub, "func", phys_json_with_run));
    elseif any(fn == phys_json_without_run)
        downloadOne(funcDirId, phys_json_without_run, fullfile(sub, "func", phys_json_without_run));
    end

    % Auto-detect echoes for this run (nii.gz + json)
    % Example: sub-03_task-handgrasp_run-1_echo-2_bold.nii.gz
    patNii  = sprintf("^%s_task-%s_run-%d_echo-(\\d+)_bold\\.nii\\.gz$", sub, task, run);
    patJson = sprintf("^%s_task-%s_run-%d_echo-(\\d+)_bold\\.json$",    sub, task, run);

    niiMatches  = fn(~[f.directory])';
    niiSel  = regexp(niiMatches, patNii,  "once");
    jsonSel = regexp(niiMatches, patJson, "once");

    niiFiles  = niiMatches(~cellfun(@isempty, niiSel));
    jsonFiles = niiMatches(~cellfun(@isempty, jsonSel));

    if isempty(niiFiles)
        error("No matching BOLD NIfTI files found for %s run-%d task-%s", sub, run, task);
    end

    % Download all detected echoes (NIfTI + JSON sidecars if present)
    for k = 1:numel(niiFiles)
        file = niiFiles(k);
        downloadOne(funcDirId, file, fullfile(sub, "func", file));
    end
    for k = 1:numel(jsonFiles)
        file = jsonFiles(k);
        downloadOne(funcDirId, file, fullfile(sub, "func", file));
    end
end

fprintf("\nDone. Data saved under:\n  %s\n", destRoot);

end
