function [fh, plotImage] = plotND(this, varargin)
%plots an MR image per slice
%
%   Y  = MrImage
%   fh = Y.plot('ParameterName', ParameterValue)
%
% IN
%   varargin    'ParameterName', 'ParameterValue'-pairs for the following
%               properties:
%               'plotType'          Type of plot that is created
%                                       'montage'   images are plotted as
%                                                   montages
%                                       'labeledMontage'
%                                                   as montage, but with
%                                                   labels (default)
%                                       'overlay'   overlays of images are
%                                                   plotted with different
%                                                   colormaps (e.g. for
%                                                   activation maps, mask
%                                                   visualization)
%                                       'spm'       uses display functions
%                                                   from SPM (spm_display/
%                                                   spm_check_registration)
%                                                   to visualize 3D volumes
%                                                   with header information
%                                                   applied ("world space")
%                                                   Note: if multiple
%                                                   selected volumes are
%                                                   specified,
%                                                   spm_check_registration
%                                                   is used
%                                       'spmInteractive' /'spmi'
%                                                   same as SPM, but keeps
%                                                   temporary nifti files to
%                                                   allow clicking into spm
%                                                   figure
%                                       '3D'/'3d'/'ortho'
%                                                   See also view3d plot3
%                                                   Plots 3 orthogonal
%                                                   sections
%                                                   (with CrossHair) of
%                                                   3D image interactively
%
%               'displayRange'      [1,2] vector for pixel value = black and
%                                                    pixel value = white
%               'signalPart'        for complex data, defines which signal
%                                   part shall be extracted for plotting
%                                       'all'       - take signal as is
%                                                     (default for
%                                                     real-valued data)
%                                       'abs'       - absolute value
%                                                     (default for complex
%                                                     data)
%                                       'phase'     - phase of signal
%                                       'real'      - real part of signal
%                                       'imag'      - imaginary part of
%                                                     signal
%               'plotMode'          transformation of data before plotting
%                                   'linear' (default), 'log'
%               'rotate90'          default: 0; 0,1,2,3; rotates image
%                                   by multiple of 90 degrees AFTER
%                                   flipping slice dimensions
%               'useSlider'         true or false
%                                   provides interactive slider for
%                                   slices/volumes
%               'colorMap'          string, any matlab colormap name
%                                   e.g. 'jet', 'gray'
%               'colorBar',         'on' or 'off' (default)
%                                   where applicable, determines whether
%                                   colorbar with displayRange shall be plotted
%                                   in figure;
%               'overlayImages'     (cell of) MrImages that will be
%                                   overlayed
%               'overlayMode'       'edge', 'mask', 'map'
%                                   'edge'  only edges of overlay are
%                                           displayed
%                                   'mask'  every non-zero voxel is
%                                           displayed (different colors for
%                                           different integer values, i.e.
%                                           clusters'
%                                   'map'   thresholded map in one colormap
%                                           is displayed (e.g. spmF/T-maps)
%                                           thresholds from
%                                           overlayThreshold
%               'overlayThreshold'  [minimumThreshold, maximumThreshold]
%                                   tresholds for overlayMode 'map'
%                                   default: [-Inf, Inf] = [minValue, maxValue]
%                                   everything below minValue will not be
%                                   displayed;
%                                   everything above maxValue
%                                   will have brightest color
%               'overlayAlpha'      transparency value of overlays
%                                   (0 = transparent; 1 = opaque; default: 0.1)
%
%               data selection      data selection uses MrImage.select/
%                                   MrImage.dimInfo.select
%               'dimLabel'          scalar or vector with array indices or
%                                   sampling points
%               'imagePlotDim'      1x3 vector of dimensions or cell array
%                                   of labels that constitue the image that
%                                   will be plotted, i.e. which three
%                                   dimensions define the volume that will
%                                   be plotted within one figure, e.g.
%                                   [1,2,3] (default)
%                                   {'x', 'y', 'z'}
%               Orientation changes:
%               'sliceDimension'    (default: 3) determines which dimension
%                                   shall be plotted as a slice
%               'rotate90'          default: 0; 0,1,2,3; rotates image
%                                   by multiple of 90 degrees AFTER
%                                   flipping slice dimensions
%               for montage plots:
%               'nRows'             default: NaN (automatic calculation)
%               'nCols'             default NaN (automatic calculation)
%               'FontSize'          font size of tile labels of montage
%               'plotTitle'         if true, title i.e. readible name of
%                                   image is put in plot
%               'plotLabels'        if true, slice labels are put into
%                                   montage
%
% OUT
%   fh          [nFigures,1] vector of figure handles
%
% EXAMPLE
%
%   Y.plot('selectedVolumes', [6:10])
%   Y.plot('displayRange', [0 1000])
%   Y.plot('useSlider', true, 'selectedVolumes', Inf);
%
%   See also
%
% Author:   Saskia Klein & Lars Kasper
% Created:  2014-05-21
% Copyright (C) 2014 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the Zurich fMRI Analysis Toolbox, which is released
% under the terms of the GNU General Public Licence (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%
% $Id: plot.m 192 2015-06-23 23:07:09Z lkasper $

% check whether image object has data
if isempty(this.data)
    error('Data matrix empty for MrImage-object %s', this.name);
end
%% set defaults
% default signal part and plot mode
if isreal(this)
    defaults.signalPart         = 'all';
else
    defaults.signalPart         = 'abs';
end
defaults.plotMode               = 'linear';


% plot appearance
defaults.plotType               = 'labeledMontage';

defaults.nRows                  = NaN;
defaults.nCols                  = NaN;
defaults.FontSize               = 10;
defaults.plotTitle              = true;
defaults.plotLabels             = true;

defaults.rotate90               = 0;
defaults.sliceDimension         = 3;
defaults.displayRange           = [];
defaults.useSlider              = false;
defaults.colorMap               = 'gray';
defaults.colorBar               = 'off';
defaults.imagePlotDim           = [1,2,3];

% overlay parameters
defaults.overlayImages          = {};
defaults.overlayMode            = 'mask';
defaults.overlayThreshold       = [];
defaults.overlayAlpha           = 0.1;

% get arguments
[args, ~] = propval(varargin, defaults);
strip_fields(args);

% check colorbar and overlays
doPlotColorBar = strcmpi(colorBar, 'on');
doPlotOverlays = any(strcmpi(plotType, {'overlay', 'overlays'})) || ...
    ~isempty(overlayImages);

% convert imagePlotDim from label to index
if iscell(imagePlotDim)
    [~, imagePlotDim] = ismember(imagePlotDim, this.dimInfo.dimLabels);
end

%% select plot data as plotImage (dimension selection)

% check whether any input parameters specify which data to plot
plotDataSpecified = any(ismember(this.dimInfo.dimLabels(:), varargin(1:2:end)));

plotImage = this.copyobj;


% select plot data
if plotDataSpecified % do nothing if specified by varargin
    [plotImage, ~, ~] = plotImage.select(varargin);
    
else % make data selection array based on imagePlotDim
    dimNotSelected = setdiff(1:plotImage.dimInfo.nDims, imagePlotDim);
    % now set all not selected dimensions to one
    if ~isempty(dimNotSelected)
        for nDataSel = dimNotSelected
            selectionArray.(plotImage.dimInfo.dimLabels{nDataSel}) = 1;
        end
        [plotImage, ~, ~] = plotImage.select(selectionArray);
    end
end


%% extract signal part, plot mode and display range

% signal part
switch signalPart
    case 'all'
        % do nothing, leave dataPlot as is
    case 'abs'
        plotImage = abs(plotImage);
    case {'angle', 'phase'}
        plotImage = angle(plotImage) + pi;
    case 'real'
        plotImage = real(plotImage);
    case 'imag'
        plotImage = imag(plotImage);
end

% linear or logarithmic plot
switch plotMode
    case 'linear' % nothing happens
    case 'log'
        plotImage = log(abs(plotImage));
end

% display range
if isempty(displayRange)
    if islogical(plotImage.data) % for logical arrays (masks)
        displayRange = [0 1];
    else
        displayRange = [min(plotImage), ...
            prctile(plotImage,98)];
    end
end


% Manipulate orientation for plot
switch sliceDimension
    case 1
        plotImage = permute(plotImage, [3 2 1 4]);
    case 2
        plotImage = permute(plotImage, [1 3 2 4]);
    case 3
        %   as is...
end

if rotate90
    plotImage = rot90(plotImage, rotate90);
end

% Permute non-singleton dimension to front, in case slice from other
% orientation were used
plotImage = permute(plotImage, find(plotImage.geometry.nVoxels>1));


%% extract data for overlay image (TODO)

% Assemble parameters for data extraction into one structure
% argsExtract = struct('sliceDimension', sliceDimension, ...
%     'selectedX', selectedX, 'selectedY', selectedY, ...
%     'selectedSlices', selectedSlices, 'selectedVolumes', selectedVolumes, ...
%     'plotMode', plotMode, 'rotate90', rotate90, 'signalPart', signalPart);

% retrieve plot data without actually plotting...
% if doPlotOverlays
%     argsOverlays = struct('sliceDimension', sliceDimension, ...
%         'selectedSlices', selectedSlices, 'selectedVolumes', selectedVolumes, ...
%         'plotMode', plotMode, 'rotate90', rotate90, 'signalPart', signalPart, ...
%         'overlayMode', overlayMode, 'overlayThreshold',  overlayThreshold, ...
%         'doPlot', true);
%
%     [fh, dataPlot] = this.plot_overlays(overlayImages, argsOverlays);
%     return
% else
%     if isempty(displayRange)
%         [dataPlot, displayRange] = this.extract_plot_data(argsExtract);
%     else
%         dataPlot = this.extract_plot_data(argsExtract);
%     end
% end

%% plot

% slider view (TODO)
if useSlider
    % useSlider is not a plotType, since it shall be combined with all
    % plot-types (overlays, montages) in a later version of this code
    %
    % sliderNd(dataPlot, @plotFun, iDimsToPlot, iDimsToLoop, labelDimsToLoop)
    %
    % display-ranges? determined internally! (as now...)
    
else % different plot types: montage, 3D, spm
    switch lower(plotType)
        case {'montage', 'labeledmontage'} % this is the default setting
            % make labels
            if strcmpi(plotType, 'labeledMontage')
                stringLabels = cellfun(@(x) num2str(x, '%3.1f'), ...
                    num2cell(plotImage.dimInfo.samplingPoints{imagePlotDim(3)}),...
                    'UniformOutput', false);
            else
                stringLabels = [];
            end
            
            % which dims need their own figure, i.e. are not in the image?
            dimsWithFig = setdiff(1:plotImage.dimInfo.nDims, imagePlotDim);
            % how many additional dims are given
            nDimsWithFig = length(dimsWithFig);
            % extract plot data and sort
            plotData = permute(plotImage.data, [imagePlotDim, dimsWithFig]);
            % number of samples in imagePlotDim
            nSamplesImagePlotDim = plotImage.dimInfo.nSamples(imagePlotDim);
            % number of samples in dimsWithFig
            nSamplesDimsWithFig = plotImage.dimInfo.nSamples(dimsWithFig);
            % reshape plot data to 4D matrix
            plotData = reshape(plotData, ...
                nSamplesImagePlotDim(1), nSamplesImagePlotDim(2), nSamplesImagePlotDim(3), []);
            % total number of figures
            nFigures = size(plotData, 4);
            
            % now plot
            for n = 1:nFigures
                % make title string
                titleString = [];
                for nTitle = 1:nDimsWithFig % number of labels in the title
                    % pos of label in dimInfo.dimLabel
                    labelPos = dimsWithFig(nTitle);
                    % subscript for dimInfo.samplingPoints from n
                    % nifti has max 7 dimensions, 3 are already within each
                    % figure --> max 4 remaining dimensions
                    [J, K, L, M] = ind2sub(nSamplesDimsWithFig, n);
                    % sampling position in one matrix
                    samplingPos = [J, K, L, M];
                    % build title string from label and corresponding sampling position
                    titleString = [titleString, ...
                        plotImage.dimInfo.dimLabels{labelPos}, ...
                        num2str(plotImage.dimInfo.samplingPoints{labelPos}(samplingPos(nTitle)), ...
                        '%4.0f')]; %#ok<AGROW>
                end
                
                % add info to figure title, if only one slice
                if numel(stringLabels) == 1
                    titleString = plotImage.dimInfo.index2label(1,3);
                    titleString = titleString{1}{1};
                end
                
                titleString = [plotImage.name, ' ', titleString];
                % open figure
                fh(n,1) = figure('Name', titleString);
                % montage
                
                if plotLabels
                    labeled_montage(permute(plotData(:,:,:,n), [1, 2, 4, 3]), ...
                        'DisplayRange', displayRange, ...
                        'LabelsIndices', stringLabels, ...
                        'Size', [nRows nCols], ...
                        'FontSize', FontSize);
                else
                    labeled_montage(permute(plotData(:,:,:,n), [1, 2, 4, 3]), ...
                        'DisplayRange', displayRange, ...
                        'LabelsIndices', {}, ...
                        'Size', [nRows nCols], ...
                        'FontSize', FontSize);
                end
                
                 set(gca, 'DataAspectRatio', ...
                     abs(plotImage.geometry.resolution_mm));

                % Display title, colorbar, colormap, if specified
                if plotTitle
                    title(titleString);
                end
                
                if doPlotColorBar
                    colorbar;
                end
                colormap(colorMap);

            end
            %
            
        case {'3d', 'ortho'} %(TODO)
            %         this.plot3d(argsExtract);
        case {'spm', 'spminteractive', 'spmi'} %(TODO)
            %             % calls spm_image-function (for single volume) or
            %             % spm_check_registration (multiple volumes)
            %
            %             % get current filename, make sure it is nifti-format
            %             fileName = this.parameters.save.fileName;
            %             fileNameNifti = fullfile(this.parameters.save.path, ...
            %                 regexprep(fileName, '\..*$', '\.nii'));
            %
            %             % create nifti file, if not existing
            %             % TODO: how about saved objects with other file names
            %             if ~exist(fileNameNifti, 'file')
            %                 this.save(fileNameNifti);
            %             end
            %
            %             % select Volumes
            %             fileNameVolArray = get_vol_filenames(fileNameNifti);
            %
            %             % display image
            %             if numel(selectedVolumes) > 1
            %                 spm_check_registration( ...
            %                     fileNameVolArray{selectedVolumes});
            %             else
            %                 spm_image('Display', fileNameVolArray{selectedVolumes});
            %             end
            %
            %             % delete temporary files for display
            %             if strcmpi(this.parameters.save.keepCreatedFiles, 'none')
            %
            %                 switch lower(plotType)
            %                     case {'spminteractive', 'spmi'}
            %                         input('Press Enter to leave interactive mode');
            %                 end
            %
            %                 delete(fileNameNifti);
            %                 [stat, mess, id] = rmdir(this.parameters.save.path);
            %             end
            %
            %             % restore original file name
            %             this.parameters.save.fileName = fileName;
            
            
    end % plotType
end % use Slider
end