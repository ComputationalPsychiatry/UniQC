function tapas_uniqc_download_example_data_openneuro_ds004662(destRoot, doOverwrite)
% tapas_uniqc_download_example_data_openneuro_ds004662(destRoot)
%
% Downloads a small, reproducible subset of OpenNeuro ds004662 (snapshot 1.1.0)
% for UniQC examples, using only MATLAB web access (no datalad/git-annex/jq).
%
% Subset:
%   sub-003 run-1 (low motion)
%   sub-004 run-1 (moderate motion)
%   sub-008 run-2 (high motion)
%   sub-001 run-2 (very high motion)
%
% Output (BIDS-preserved) under:
%   destRoot/sub-XXX/func/<files>
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
baseOpts = weboptions("MediaType","application/json", "Timeout", 60);

gql = @(query) webwrite(graphqlUrl, struct("query", query), baseOpts);

    function files = listTree(treeKey)
        if nargin < 1 || strlength(treeKey)==0
            q = sprintf(['query { snapshot(datasetId: "%s", tag: "%s") { ' ...
                         'files { filename directory key urls size } } }'], datasetId, snapshotTag);
        else
            q = sprintf(['query { snapshot(datasetId: "%s", tag: "%s") { ' ...
                         'files(tree: "%s") { filename directory key urls size } } }'], datasetId, snapshotTag, treeKey);
        end
        r = gql(q);
        if ~isfield(r, 'data') || ~isfield(r.data,'snapshot') || ~isfield(r.data.snapshot,'files')
            error("OpenNeuro API response did not include expected fields.");
        end
        files = r.data.snapshot.files;
    end

    function key = findDirKey(parentKey, dirname)
        f = listTree(parentKey);
        key = "";
        for i = 1:numel(f)
            if isfield(f(i),'directory') && f(i).directory && string(f(i).filename) == dirname
                key = string(f(i).key);
                return
            end
        end
    end

    function [url, found] = findFileUrl(treeKey, filename)
        f = listTree(treeKey);
        url = "";
        found = false;
        for i = 1:numel(f)
            if ~f(i).directory && string(f(i).filename) == filename
                found = true;
                if isfield(f(i),'urls') && ~isempty(f(i).urls)
                    % urls might be a cell array of strings/chars
                    u = f(i).urls;
                    if iscell(u), url = string(u{1}); else, url = string(u(1)); end
                end
                return
            end
        end
    end

    function downloadOne(treeKey, filename, relPath)
        outFile = fullfile(destRoot, relPath);
        if exist(outFile, 'file')
            fprintf("✓ exists: %s\n", relPath);
            return
        end

        [url, found] = findFileUrl(treeKey, filename);
        if ~found
            error("File not found in snapshot tree: %s", filename);
        end
        if strlength(url)==0
            error("No download URL returned for: %s", filename);
        end

        outDir = fileparts(outFile);
        if ~exist(outDir, 'dir'); mkdir(outDir); end

        fprintf("↓ %s\n", relPath);
        websave(outFile, url, weboptions("Timeout", 120)); %#ok<WEBSAVE>
    end

    function downloadT1wAnat(subKey, sub)
        % Download anatomical T1w NIfTI + JSON for a given subject.
        % Common BIDS layout: sub-XX/anat/*_T1w.(nii.gz|json)
        % (If the dataset uses sessions, you can extend this similarly for ses-*/anat.)

        anatKey = findDirKey(subKey, "anat");
        if strlength(anatKey)==0
            fprintf("(i) No anat directory for %s (skipping T1w)\n", sub);
            return
        end

        fAnat = listTree(anatKey);
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
            downloadOne(anatKey, file, fullfile(sub, "anat", file));
        end
        for k = 1:numel(t1json)
            file = t1json(k);
            downloadOne(anatKey, file, fullfile(sub, "anat", file));
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

% --- Main download loop --------------------------------------------------
for p = 1:size(pairs,1)
    sub = string(pairs{p,1});
    run = pairs{p,2};

    fprintf("\n=== %s run-%d ===\n", sub, run);

    subKey = findDirKey("", sub);
    if strlength(subKey)==0
        error("Could not find subject directory at root: %s", sub);
    end

    % Anatomical T1w (if present)
    downloadT1wAnat(subKey, sub);

    funcKey = findDirKey(subKey, "func");
    if strlength(funcKey)==0
        error("Could not find func directory for %s", sub);
    end

    % List func files once, then select what we need
    f = listTree(funcKey);
    fn = string({f.filename});

    % Events (if present)
    ev = sprintf("%s_task-%s_run-%d_events.tsv", sub, task, run);
    if any(fn == ev)
        downloadOne(funcKey, ev, fullfile(sub, "func", ev));
    end

    % Auto-detect echoes for this run (nii.gz + json)
    % Example: sub-003_task-handgrasp_run-1_echo-2_bold.nii.gz
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
        downloadOne(funcKey, file, fullfile(sub, "func", file));
    end
    for k = 1:numel(jsonFiles)
        file = jsonFiles(k);
        downloadOne(funcKey, file, fullfile(sub, "func", file));
    end
end

fprintf("\n✔ Done. Data saved under:\n  %s\n", destRoot);

end
