% performs transformation from geometry of
% recon-code to output of spm_read_vols
%
%
%  INPUT
%       Y  - congruent with FullImReconStackData & imagesc-orientation
%
% OUTPUT
%       Y - from spm_read_vols

function Y = transform_matrix_analyze2matlab(Y)

    for sl = 1:size(Y,3)
        Y(:,:,sl) = (fliplr(flipud(Y(:,:,sl)))).';
    end
    
end