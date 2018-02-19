function [fh, plotImage] = plot(this, varargin)
% plots an MR image
%
%   Y  = MrImage
%   fh = Y.plot('ParameterName', ParameterValue)
%
% Note:
%   The first (specified) dimension will be plotted from left to right
%   The 2nd (specified) dimensions will be plotted from down to up
%   The 3rd (and higher) specified dimensions will be plotted in tiles or
%   figures (depending on options)
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
%               'overlay'           false (default) or true if an overlay
%                                   image is plotted
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
%               'edgeThreshold'     determines where edges will be drawn,
%                                   the higher, the less edges
%                                   Note: logarithmic scale, e.g. try 0.005
%                                   if 0.05 has too little edges
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
%               'selectionType'     'index' (default) or 'label' selects
%                                   hoew 'dimlabel' vector is interpreted,
%                                   as array indices or sampling points
%
%               Orientation changes:
%               'sliceDimension'    (default: 3) determines which dimension
%                                   shall be plotted as a slice
%                                   can be entered as index or dimLabel
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
%   Y.plot('z', [6:10])
%   Y.plot('displayRange', [0 1000])
%   Y.plot('useSlider', true, 'z', []);
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

% data selection
defaults.selectionType          = 'index';


% plot appearance
defaults.plotType               = 'labeledMontage';

defaults.FigureSize             = [1600 900];
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
defaults.overlay                = false;
defaults.overlayImages          = {};
defaults.overlayMode            = 'mask';
defaults.overlayThreshold       = [];
defaults.overlayAlpha           = []; % depends on overlayMode
defaults.edgeThreshold          = [];


% get arguments
[args, ~] = propval(varargin, defaults);
strip_fields(args);

% check colorbar and overlays
doPlotColorBar = strcmpi(colorBar, 'on');
doPlotOverlays = overlay || ...
    ~isempty(overlayImages);

% convert imagePlotDim from label to index
if iscell(imagePlotDim)
    [~, imagePlotDim] = ismember(imagePlotDim, this.dimInfo.dimLabels);
end


%% select plot data as plotImage (dimension selection)

% check whether any input parameters specify which data to plot
plotDataSpecified = ismember(varargin(1:2:end), this.dimInfo.dimLabels);
% copy plot image for selection
plotImage = this.copyobj;

% select plot data
if any(plotDataSpecified)
    plotDataSpecified = repmat(plotDataSpecified, 2, 1);
    plotDataSpecified = reshape(plotDataSpecified, 1, []);
    selectStr = varargin(plotDataSpecified);
    [plotImage, ~, ~] = plotImage.select('type', selectionType, ...
        selectStr{:});
else % 1 image with all samples of first three dimensions, for all further
    % dimensions only first image is plotted
    if plotImage.dimInfo.nDims > 3
        nDimsSelect = plotImage.dimInfo.nDims - 3;
        dimLabelsSelect = plotImage.dimInfo.dimLabels;
        selectStr(1:2:nDimsSelect*2) = dimLabelsSelect(4:end);
        selectStr(2:2:nDimsSelect*2) = {1};
        plotImage = plotImage.select('type', selectionType, ...
            selectStr{:});
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
        % check whether valid display range has been specified
        % if values equal or second range larger then first, specify by
        % hand
        if diff(displayRange) <= 0
            displayRange(2) = displayRange(1) + 1;
        end
    end
end


% Manipulate orientation for plot
if ischar(sliceDimension) % convert dimLabel to index
    sliceDimension = plotImage.dimInfo.get_dim_index(sliceDimension);
end
switch sliceDimension
    case 1
        plotImage = permute(plotImage, [3 2 1 4]);
    case 2
        plotImage = permute(plotImage, [1 3 2 4]);
    case 3
        %   as is...
    otherwise
        plotImage = permute(plotImage, [1 2 sliceDimension]);
end

if rotate90
    plotImage = rot90(plotImage, rotate90);
end

%% extract data for overlay image
if doPlotOverlays
    
    % check background image is 3D image
    is3dBackground = plotImage.dimInfo.nDims == 3;
    if ~is3dBackground
        error(['Background image is not 3D but has ', ...
            num2str(plotImage.dimInfo.nDims), ' nDims']);
    end
    % extract data from background image
    % extract plot data and sort
    plotData = plotImage.data;
    backgroundNSamples = plotImage.dimInfo.nSamples;
    % set default Alpha depending on define mode'
    if isempty(overlayAlpha)
        switch overlayMode
            case {'mask', 'edge'}
                overlayAlpha = 1;
            case 'blend'
                overlayAlpha = 0.2;
            case 'map'
                overlayAlpha = 0.7;
            otherwise
                overlayAlpha = 0.1;
        end
    end
    
    % settings
    nColorsPerMap   = 256;
    
    % make sure overlay images are cell
    if ~iscell(overlayImages)
        overlayImages = {overlayImages};
    end
    overlayImages   = reshape(overlayImages, [], 1);
    
    % loop over overlays and extract data
    nOverlays       = numel(overlayImages);
    dataOverlays    = cell(nOverlays,1);
    
    for iOverlay = 1:nOverlays
        thisOverlay = overlayImages{iOverlay};
        
        %% for map: overlayThreshold image only,
        %  for mask: binarize
        %  for edge: binarize, then compute edge
        
        switch overlayMode
            case {'map', 'maps'}
                thisOverlay.apply_threshold(overlayThreshold);
            case {'mask', 'masks'}
                thisOverlay.apply_threshold(0, 'exclude');
            case {'edge', 'edges'}
                thisOverlay.apply_threshold(0, 'exclude');
                % for cluster mask with values 1, 2, ...nClusters,
                % leave values of edge same as cluster values
                thisOverlay = edge(thisOverlay,'sobel', edgeThreshold);
        end
        
        if any(plotDataSpecified)
            selectStr = varargin(plotDataSpecified);
            [plotOverlay, ~, ~] = thisOverlay.select('type', selectionType, ...
                selectStr{:});
        else
            plotOverlay = thisOverlay.copyobj;
        end
        % check that background and overlay image have same dimension
        equalDimBackgroundOverlay = ...
            plotOverlay.dimInfo.nSamples == backgroundNSamples;
        if any(~equalDimBackgroundOverlay)
            error(['Different number of samples for background (', ...
                num2str(backgroundNSamples), ') and overlay image (', ...
                num2str(plotOverlay.dimInfo.nSamples), ').']);
        end
        % extract plot data and sort
        dataOverlays{iOverlay} = plotOverlay.data;
    end
    
    
    % Define color maps for different cases:
    %   map: hot
    %   mask/edge: one color per mask image, faded colors for different
    %   clusters within same mask
    
    functionHandleColorMaps = {
        @hot
        @cool
        @spring
        @summer
        @winter
        @jet
        @hsv
        };
    
    overlayColorMap = cell(nOverlays,1);
    switch overlayMode
        case {'mask', 'edge', 'masks', 'edges'}
            baseColors = hsv(nOverlays);
            
            % determine unique color values and make color map
            % a shaded version of the base color
            for iOverlay = 1:nOverlays
                indColorsOverlay = unique(dataOverlays{iOverlay});
                nColorsOverlay = max(2, round(...
                    max(indColorsOverlay) - min(indColorsOverlay)));
                overlayColorMap{iOverlay} = get_brightened_color(...
                    baseColors(iOverlay,:), 1:nColorsOverlay - 1, ...
                    nColorsOverlay -1, 0.7);
                
                % add for transparency
                overlayColorMap{iOverlay} = [0,0,0; ...
                    overlayColorMap{iOverlay}];
            end
            
        case {'map', 'maps'}
            for iOverlay = 1:nOverlays
                overlayColorMap{iOverlay} = ...
                    functionHandleColorMaps{iOverlay}(nColorsPerMap);
            end
            
    end
    
    % Assemble RGB-image for montage by adding overlays with transparency as
    % RGB in right colormap
    rangeOverlays   = cell(nOverlays, 1);
    rangeImage      = cell(nOverlays, 1);
    
    for iOverlay = 1:nOverlays
        [plotData, rangeOverlays{iOverlay}, rangeImage{iOverlay}] = ...
            add_overlay(plotData, dataOverlays{iOverlay}, ...
            overlayColorMap{iOverlay}, ...
            overlayThreshold, ...
            overlayAlpha);
    end
end
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
            if strcmpi(plotType, 'labeledMontage') && plotImage.dimInfo.nDims >= 3
                stringLabels = cellfun(@(x) num2str(x, '%3.1f'), ...
                    num2cell(plotImage.dimInfo.samplingPoints{imagePlotDim(3)}),...
                    'UniformOutput', false);
            else
                stringLabels = [];
            end
            
            % which dims need their own figure, i.e. are not in the image?
            dimsWithFig = setdiff(1:plotImage.dimInfo.nDims, imagePlotDim);
            if isempty(dimsWithFig), dimsWithFig = 4; end % for 3D data
            % how many additional dims are given
            nDimsWithFig = length(dimsWithFig);
            % extract plot data and sort
            if ~doPlotOverlays
                plotData = permute(plotImage.data, [imagePlotDim, dimsWithFig]);
                % number of samples in imagePlotDim
                nSamplesImagePlotDim = plotImage.dimInfo.nSamples(imagePlotDim(1:min(plotImage.dimInfo.nDims,3)));
                % reshape plot data to 4D matrix
                if plotImage.dimInfo.nDims > 3
                    % number of samples in dimsWithFig
                    nSamplesDimsWithFig = plotImage.dimInfo.nSamples(dimsWithFig);
                    plotData = reshape(plotData, ...
                        nSamplesImagePlotDim(1), nSamplesImagePlotDim(2), nSamplesImagePlotDim(3), []);
                else
                    % number of samples in dimsWithFig
                    nSamplesDimsWithFig = 1;
                end
                % total number of figures
                nFigures = size(plotData, 4);
            else
                nDimsWithFig = 1;
                nFigures = 1;
                nSamplesDimsWithFig = 1;
            end
            
            % now plot
            for n = 1:nFigures
                % make title string
                titleString = [];
                % sampling positions for titleString
                samplingPosArray = cell(1,nDimsWithFig);
                % convert index to subscript values for titleString
                [samplingPosArray{:}] = ind2sub(nSamplesDimsWithFig, n);
                % loop over nDimsWithFig
                for nTitle = 1:nDimsWithFig % number of labels in the title
                    % pos of label in dimInfo.dimLabel
                    labelPos = dimsWithFig(nTitle);
                    % build title string from label and corresponding sampling position
                    
                    if labelPos <= plotImage.dimInfo.nDims % 3D and smaller, have no label!
                        titleString = [titleString, ...
                            plotImage.dimInfo.dimLabels{labelPos}, ...
                            num2str(plotImage.dimInfo.samplingPoints{labelPos}(samplingPosArray{nTitle}), ...
                            '%4.0f') ' ']; %#ok<AGROW>
                    end
                end
                
                % add info to figure title, if only one slice
                if numel(stringLabels) == 1
                    titleString = plotImage.dimInfo.index2label(1,3);
                    titleString = titleString{1}{1};
                end
                
                titleString = str2label([plotImage.name, ' ', titleString]);
                % open figure
                fh(n,1) = figure('Name', titleString, 'Position', ...
                    [1 1 FigureSize(1), FigureSize(2)], 'WindowStyle', 'docked');
                % montage
                if doPlotOverlays
                    thisPlotData = plotData;
                else
                    thisPlotData = permute(plotData(:,:,:,n), [1, 2, 4, 3]);
                end
                if plotLabels
                    labeled_montage(thisPlotData, ...
                        'DisplayRange', displayRange, ...
                        'LabelsIndices', stringLabels, ...
                        'Size', [nRows nCols], ...
                        'FontSize', FontSize);
                else
                    labeled_montage(thisPlotData, ...
                        'DisplayRange', displayRange, ...
                        'LabelsIndices', {}, ...
                        'Size', [nRows nCols], ...
                        'FontSize', FontSize);
                end
                
                resolution_mm = abs(plotImage.dimInfo.resolutions);
                resolution_mm(isnan(resolution_mm)) = 1;
                resolution_mm((end+1):3) = 1;
                resolution_mm(4:end) = [];
                set(gca, 'DataAspectRatio', ...
                    resolution_mm);
                
                % Display title, colorbar, colormap, if specified
                if plotTitle
                    title(titleString);
                end
                
                if doPlotColorBar
                    colorbar;
                end
                colormap(colorMap);
                drawnow;
            end
            %
            
        case {'3d', 'ortho'} %(TODO)
            %         this.plot3d(argsExtract);
        case {'spm', 'spminteractive', 'spmi'} %(TODO)
            % calls spm_image-function (for single volume) or
            % spm_check_registration (multiple volumes)
            
            % get current filename, make sure it is nifti-format
            fileName = this.parameters.save.fileName;
            fileNameNifti = fullfile(this.parameters.save.path, ...
                regexprep(fileName, '\..*$', '\.nii'));
            doDelete = false;
            % create nifti file, if not existing and take note to delete it
            % afterwards
            % TODO: how about saved objects with other file names
            if ~exist(fileNameNifti, 'file')
                this.save('fileName', fileNameNifti);
                doDelete = true;
            end
            
            % select Volumes
            fileNameVolArray = get_vol_filenames(fileNameNifti);
            
            % display image
            if numel(fileNameVolArray) > 1
                spm_check_registration(fileNameVolArray);
            else
                spm_image('Display', fileNameVolArray{1});
            end
            
            % delete temporary files for display
            if strcmpi(this.parameters.save.keepCreatedFiles, 'none')
                
                switch lower(plotType)
                    case {'spminteractive', 'spmi'}
                        input('Press Enter to leave interactive mode');
                end
                
                if doDelete
                    delete(fileNameNifti);
                    [fp, fn] = fileparts(fileNameNifti);
                    fileNameDimInfo = fullfile(fp, [fn '_dimInfo.mat']);
                    delete(fileNameDimInfo);
                    [stat, mess, id] = rmdir(this.parameters.save.path);
                end
            end
            
            % restore original file name
            this.parameters.save.fileName = fileName;
            
            
    end % plotType
end % use Slider
end