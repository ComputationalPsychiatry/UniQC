% create file names of spm-analyze files for fMRI session w/ multiple vols
% 
% INPUT
%   fn      - filename
%   Ivols   - indices of all volumes to be considered
%   nifti_flag - 1 to make nifti-compatible output, not analyze
function fnames = get_vol_filenames(fn, Ivols, nifti_flag)

cIvols = num2cell(Ivols);
if nargin >2 && nifti_flag==1
    fnames = cellfun(@(x) sprintf('%s,%d',fn,x),cIvols, 'UniformOutput', false);
else
    fnames = cellfun(@(x) sprintf('%s_%04d.img',fn,x),cIvols, 'UniformOutput', false);
end

