% performs transformation from geometry of
% recon-code to output of spm_read_vols
%
%
%  INPUT
%       Y  - congruent with FullImReconStackData & imagesc-orientation
%
% OUTPUT
%       Y - from spm_read_vols

function Y = transformMatlab2AnalyzeSpace(Y)

    for sl = 1:size(Y,3)
         Y(:,:,sl) = flipud(fliplr(Y(:,:,sl).'));
%          Y(:,:,sl) = (Y(:,:,sl).');  
    end
    
end