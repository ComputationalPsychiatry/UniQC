% Script demo_fmri_analysis_paradigm_visual
% Demonstrates whole fmri analysis for dataset with visual paradigm and
% physiological noise modeling from peripheral data
%
%  demo_fmri_analysis_paradigm_visual
%
% FQSM_005
%
%   See also
%
% Author:   Lars Kasper (kasper@biomed.ee.ethz.ch)
% Created:  2015-11-24
% Copyright (C) 2015 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich MR-Technology Group Recon Repository,
% which is copyright-protected and licensed under conditions described at:
%
% http://chap04.ethz.ch/redmine/projects/recon/documents
%
% Contact the author or institute before using this code.

%
 
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setup paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
paths.study = '/usr/ibtnas01/scratch-02/mritrans/kasperla/FQSM/data';
dirs.subject = 'FQSM_005_2015_11_24_withECG';
dirs.raw = 'raw';
dirs.phys = 'logs/phys';
dirs.behav = 'logs/behav';
dirs.fmri = 'fmri';
dirs.struct = 'struct';
dirs.glm = 'glm';

ids.struct.t1 = 4;
ids.struct.epiwb = 17; %whole brain
ids.struct.angio = 14;
ids.fmri.visual = 12;
ids.fmri.rest = 19;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Determine dependent paths/file names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

paths.subject = fullfile(paths.study, dirs.subject);

dirArray = setdiff(fieldnames(dirs), 'subject');
nDirs = numel(dirArray);
for d = 1:nDirs
    paths.(dirArray{d}) = fullfile(paths.subject, dirs.(dirArray{d}));
    [tmp, tmp2] = mkdir(paths.(dirArray{d}));
end
%%

doCopy = true

typeArray = fieldnames(ids);
nTypes = numel(typeArray);

for t = 1:nTypes
scanType = typeArray{t};
    
idArray = fieldnames(ids.(scanType));
nIds = numel(idArray);

for id = 1:nIds
    scanId = idArray{id};
    rawfile = ...
        tapas_physio_get_filename_from_id_philips(ids.(scanType).(scanId), ...
        paths.raw);
    
    rawfiles.(scanType).(scanId) = rawfile;
    [~,~,ext] = fileparts(rawfile);
    
    if doCopy
        copyfile( fullfile(paths.raw, rawfile), ...
            fullfile(paths.(scanType), [scanId ext]));
    end
    
end

% fnPhyslogArray = tapas_physio_find_matching_scanphyslog_philips(...
%         fnImageArray, pathLogFiles);

end