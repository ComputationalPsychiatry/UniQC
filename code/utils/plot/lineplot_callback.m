function currentMousePosition = lineplot_callback(hObject, eventdata, Img, ...
    hAxLinePlot)
% provides a callback function to plot the non-displayed dimension in a
% figure display
%
%   currentMousePosition = lineplot_callback(hObject, eventdata, Img, ...
%                               hAxLinePlot)
%
% IN
%
% OUT
%
% EXAMPLE
%    hCallback = @(x,y) lineplot_callback(x, y, this, hAxLinePlot);
%    ha.ButtonDownFcn = hCallback;
%    MrImage.plot('linkOptions', 'ts_4')
%
%   See also MrImage.plot demo_plot_images

% Author:   Saskia Bollmann & Lars Kasper
% Created:  2018-12-28
% Copyright (C) 2018 Institute for Biomedical Engineering
%                    University of Zurich and ETH Zurich
%
% This file is part of the TAPAS UniQC Toolbox, which is released
% under the terms of the GNU General Public License (GPL), version 3.
% You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version).
% For further details, see the file COPYING or
%  <http://www.gnu.org/licenses/>.
%

% mouse position found on different (sub-)0bjects, depending on caller
% (figure, axes or image itself)
switch class(hObject)
    case 'matlab.ui.Figure'
        currentMousePosition = round(hObject.Children(1).CurrentPoint(1,1:2));
        hf = hObject;
    case 'matlab.graphics.axis.Axes'
        currentMousePosition = round(hObject.CurrentPoint(1,1:2));
        hf = hObject.Parent;
    case 'matlab.graphics.primitive.Image'
        currentMousePosition = round(hObject.Parent.CurrentPoint(1,1:2));
        hf = hObject.Parent.Parent;
end

disp(currentMousePosition);
stringTitle = sprintf('%s on %s at (%d,%d)', eventdata.EventName, class(hObject), ...
    currentMousePosition(1), currentMousePosition(2));
disp(stringTitle);

% update current plot data by tim series from current voxel
nSamples =  Img.dimInfo.nSamples(1:2); % TODO: dimensionality independence
if all(currentMousePosition <= nSamples) && all(currentMousePosition >= 1);
    % add current mouse position and respective plot data to figure
    % UserData variable
    currentPlotData = squeeze(Img.data(currentMousePosition(1), ...
        currentMousePosition(2),1,:));
    hf.UserData.PlotData(:,1) = currentPlotData;
    hf.UserData.MousePositions(1,:) = currentMousePosition;
    switch eventdata.EventName
        case 'Hit'
            % add new fixed line from time series of current voxel to plot
            hf.UserData.MousePositions(end+1,:) = currentMousePosition;
            hf.UserData.PlotData(:,end+1) = currentPlotData;
        otherwise
            % just replace current line
    end
    guidata(hf);
    plot(hAxLinePlot, hf.UserData.PlotData);
    title(hAxLinePlot, stringTitle);
end