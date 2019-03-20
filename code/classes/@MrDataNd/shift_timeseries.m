function shiftedY = shift_timeseries(this, dt)
% Shifts voxel trace along time dimension by fixed time using Fourier
% interpolation, and updates time vector in dimInfo
%
%   Y = MrDataNd()
%   shiftedY = Y.shift_timeseries(dt)
%
% This is a method of class MrDataNd. It heavily relies on code snippets of
% spm_slice_timing, apart from the reading/writing of niftis
%
% IN
%   dt  [1,1] time to shift (i.e., new time series will be at time points
%             t-dt) all time series
%           OR
%       [1,nSlices]
%             slice-specific time shift. Can be used for slice timing
%             correction
%           
%   
% OUT
%
% EXAMPLE
%   shift_timeseries
%
%   See also MrDataNd spm_slice_timing

% Author:   Andreea Diaconescu & Lars Kasper
% Created:  2019-03-20
% Copyright (C) 2019 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.

%-Slice timing correction
%==========================================================================

if numel(dt) == 1
    shiftamount = dt*ones(1, this.dimInfo.z.nSamples); % all slices shifted by same amount!
else
    shiftamount = dt;
end

subj = 1;
Vout(1).dim = this.dimInfo.nSamples({'x','y','z'});

nimgo = this.dimInfo.t.nSamples;
nimg  = 2^(floor(log2(nimgo))+1);

% Set up [time x voxels] matrix for holding image info
% slices = zeros([Vout(1).dim(1:2) nimgo]);
stack  = zeros([nimg Vout(1).dim(1)]);

allSlices = zeros(this.dimInfo.nSamples);

task = sprintf('Correcting acquisition delay: session %d', subj);
spm_progress_bar('Init',nslices,task,'planes complete');

% For loop to perform correction slice by slice
for k = 1:nslices
    
    % Read in slice data
    % TODO: spm_slice_vol uses trilinear interpolation in this setting.
    % Do we need this as well? Maybe only if data not rewritten before?
    %         B  = spm_matrix([0 0 k]);
    %         for m=1:nimgo
    %             slices(:,:,m) = spm_slice_vol(Vin(m),B,Vin(1).dim(1:2),1);
    %         end
    %
    % [nX,nY,nVolumes] 
    sliceY = this.select('z',k, 'removeDims', true);
    slices = sliceY.data;
    
    % Set up shifting variables
    len     = size(stack,1);
    phi     = zeros(1,len);
    
    % Check if signal is odd or even -- impacts how Phi is reflected
    %  across the Nyquist frequency. Opposite to use in pvwave.
    OffSet  = 0;
    if rem(len,2) ~= 0, OffSet = 1; end
    
    % Phi represents a range of phases up to the Nyquist frequency
    % Shifted phi 1 to right.
    for f = 1:len/2
        phi(f+1) = -1*shiftamount(k)*2*pi/(len/f);
    end
    
    % Mirror phi about the center
    % 1 is added on both sides to reflect Matlab's 1 based indices
    % Offset is opposite to program in pvwave again because indices are 1 based
    phi(len/2+1+1-OffSet:len) = -fliplr(phi(1+1:len/2+OffSet));
    
    % Transform phi to the frequency domain and take the complex transpose
    shifter = [cos(phi) + sin(phi)*sqrt(-1)].';
    shifter = shifter(:,ones(size(stack,2),1)); % Tony's trick
    
    % Loop over columns
    for i=1:Vout(1).dim(2)
        
        % Extract columns from slices
        stack(1:nimgo,:) = reshape(slices(:,i,:),[Vout(1).dim(1) nimgo])';
        
        % Fill in continous function to avoid edge effects
        for g=1:size(stack,2)
            stack(nimgo+1:end,g) = linspace(stack(nimgo,g),...
                stack(1,g),nimg-nimgo)';
        end
        
        % Shift the columns
        stack = real(ifft(fft(stack,[],1).*shifter,[],1));
        
        % Re-insert shifted columns
        slices(:,i,:) = reshape(stack(1:nimgo,:)',[Vout(1).dim(1) 1 nimgo]);
    end
    
    % Write out the slice for all volumes
    allSlices(:,:,k,:) = permute(slices, [1 2 4 3]);
    spm_progress_bar('Set',k);
end

shiftedY = this.copyobj;

% update time vector in dimInfo
if numel(dt) == 1
    shiftedY.dimInfo.t.samplingPoints = shiftedY.dimInfo.t.samplingPoints - dt;
end