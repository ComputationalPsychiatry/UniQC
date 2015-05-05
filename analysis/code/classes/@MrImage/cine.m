function filename = cine(this, varargin)
% Saves video of multidimensional dataset to an avi-file
% TODO: make it work with any plot-function and slider4D-save option
%
%
%   Y = MrImage()
%   Y.cine(inputs)
%
% This is a method of class MrImage.
%
% IN
%   given as property name/value pairs:
%
%           movieFormat      per default 'gif' for animated gif
%           pathSave    filename inclusive path of the animated gif
%           cineDim     plot the first two dimensions, along the
%                       third.
%           speed       in frames per second (default: 1)
%
% OUT
%           filename    filename of the saved animated image, per default
%                       file is saved in the current folder with a name
%                       refering to the input filename.
%
% EXAMPLE
%   cine
%
%   See also MrImage
%
% Author:   Laetitia Vionnet
% Created:  2015-04-17
% Copyright (C) 2015 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Methods Evaluation Repository, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id$
%

defaults.movieFormat    = 'gif';
defaults.cineDim        = [1,2,3];
defaults.imageType      = 'abs'; %'abs' or 'angle'
defaults.pathSave       = pwd;
defaults.filename       = [];
defaults.speed          = 1;

args = propval(varargin, defaults);
strip_fields(args);

str_cinDim = int2str(cineDim);

if isempty(filename)
    filename = [this.name, '_', str_cinDim(str_cinDim ~= ' ') '.' movieFormat];
end

% re-arrange the data dimensions
dimData                 = size(this.data);
N                       = length(dimData);
dimDataOrder            = 1:N;
dimDataOrderNew         = 1:N;
permutations            = perms(dimDataOrder);

% find the first permutation that satisfies the cineDim order
for iCn = 1:length(permutations)
    if ~isequal(dimDataOrderNew(1:3),cineDim)
        dimDataOrderNew = permutations(iCn,:);
    end
end

% permute the data
DataPerm                = permute(this.data,dimDataOrderNew);

Data                    = DataPerm(:,:,:,1,1,1,1,1,1,1,1,1);

nColorsPerMap           = 256;
nFrame                  = size(Data,3);


figure
% first frame
switch imageType
    case 'abs'
        imagesc(abs(squeeze(Data(:,:,1))));
    case 'angle'
        imagesc(angle(squeeze(Data(:,:,1))));
end

axis tight equal
set(gca,'nextplot','replacechildren','visible','off')
colorbar; colormap('gray');

f = getframe;
[im,map] = rgb2ind(f.cdata,nColorsPerMap,'nodither');
im(1,1,1,nFrame) = 0;

for iSlice = 1:nFrame % number of frame of the animated gif
    switch imageType
        case 'abs'
            imagesc(abs(squeeze(Data(:,:,iSlice))));
        case 'angle'
            imagesc(angle(squeeze(Data(:,:,iSlice))));
    end
    
    f = getframe;
    
    for iCn = 1:round(1/speed)
        im(:,:,1,iSlice) = rgb2ind(f.cdata,map,'nodither');
    end
    
end

imwrite(im,map,fullfile(pathSave,filename),'DelayTime',0,'LoopCount',inf)

end