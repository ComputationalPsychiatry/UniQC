function [fh yMin, yMax] = plot_abs_image(Y,iDynSli,fh, yMin, yMax)
%simple plotting routine for one dynamic within a 3D-dataset
%
%   [fh yMin, yMax] = plot_image_diagnostics(Y,iDynSli,fh, yMin, yMax)
%
% IN
%   Y           [nVoxelX nVoxelY, nSlices, nVolumes] real valued data matrix
%               OR
%               [nSamples, nCoils, nDynSlis] real-valued data matrix
%   iDynSli     index of which dynamic/slice shall be plotted
%   fh          figure handle to be plotted into; if empty or missing, new figure is
%               created
%   yMin        [nPlots,1] min value in ylim, one for each set of coils, if
%               empty or missing, newly created from data limits
%   yMax        [nPlots,1] max value in ylim, one for each set of coils, if
%               empty or missing, newly created from data limits
%
% OUT
%   fh          figure handle plotted into
%   yMin        [nPlots,2] min value in ylim, one for each set of coils,
%               abs and phase
%   yMax        [nPlots,2] max value in ylim, one for each set of coils
%               abs and phase
% EXAMPLE
%   [fh yMin, yMax] = plot_image_diagnostics(Y,iDynSli,fh, yMin, yMax, coilPlots)
%
%   See also plotTrajDiagnostics guiTrajDiagnostics
%
% Author: Lars Kasper
% Created: 2013-01-06
% Copyright 2013 Institute for Biomedical Engineering, ETH/Uni Zurich.
% $Id$


if nargin < 3 || isempty(fh)
    fh = figure('Name','Video of ImageDiagnostics', 'WindowStyle', 'normal');
else
    figure(fh);
end

% determine plot limits
if nargin < 5 || isempty(yMin)
    yMin = min(min(min(Y(:,:,:,:))));
    yMax = max(max(max(Y(:,:,:,:))));
end

% plot abs data always
imagesc(Y(:,:,iDynSli));
colormap gray; axis image;
caxis([yMin, yMax]);

stringTitle = sprintf('abs, iDynSli = %d', iDynSli);
if exist('suptitle', 'builtin')
    suptitle(stringTitle);
else
    title(stringTitle);
end

end
