function pfxFileArray = prefix_files(fileArray, pfx, isSuffix)
%prefixes/or suffixes (cell of) files (incl. paths) with file prefix before file name
%
%   output = prefix_files(input)
%
% IN
%   fileArray cell(nFiles,1) or single string of filenames
%       e.g.
%            '/LK215/functional/fMRI_session_1'
%             'LK215/functional/fMRI_session_2'
%   pfx         prefix or suffix, e.g. 'r' or '_GM'
%
%   isSuffix    if false, 'rfMRI_session_1.nii.' is created (incl. path)
%               if true, 'fMRI_session_1_GM.nii' is created
% OUT
%
% EXAMPLE
%   prefix_files
%
%   See also
%
% Author: Lars Kasper
% Created: 2013-12-03
% Copyright (C) 2013 Institute for Biomedical Engineering, ETH/Uni Zurich.
% $Id$
if nargin < 3
    isSuffix = 0;
end
isArray = iscell(fileArray);
if ~isArray
    fileArray = {fileArray};
end

nFiles = length(fileArray);

pfxFileArray = cell(nFiles,1);
for f = 1:nFiles
    fn = fileArray{f};
    [f1, f2, f3] = fileparts(fn);
    if isSuffix
        pfxFileArray{f} = fullfile(f1, [f2, pfx, f3]);
    else
        pfxFileArray{f} = fullfile(f1, [pfx, f2 , f3]);
    end
end    

if ~isArray
    pfxFileArray = pfxFileArray{1};
end