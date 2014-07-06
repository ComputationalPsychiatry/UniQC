% performs transformation from geometry of
% recon-code to output of spm_read_vols
%
%
%  INPUT
%       Y  - congruent with FullImReconStackData & imagesc-orientation
%
% OUTPUT
%       newY - from spm_read_vols

function newY = transform_matrix_analyze2matlab(Y)

  newY = zeros([size(Y,2), size(Y,1), size(Y,3)]);
  for sl = 1:size(Y,3)
        newY(:,:,sl) = (fliplr(flipud(Y(:,:,sl)))).';
    end
    
end