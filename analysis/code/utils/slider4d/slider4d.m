function varargout = slider4d(varargin)
% provides interactive movie & slider frame plot capability for 3D-data and arbitrary plot functions
%
%   slider4d(Y, handlePlotFunction, nSli, yMin, yMax)
%
% IN
%  Y                    [nX,nY, nSlices, nDynamics] - will be transformed into 3D
%                       matrix described above assuming that the dimension
%                       with length nSli is the slice dim in this 4D matrix
%
%                       OR (preferred):
%                       [nSamples, nCoils, nDynSlis] data matrix,
%                       where nDynSlis is a combined slice/dynamic
%                       dimension with dynamic being the fast-changing
%                       entity, i.e. for nDyns = 7 and nSli = 3, the entry
%                       of Y would look like:
%                       iDynSli 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
%                       iSli    1 1 1 1 1 1 1 2 2  2  2  2  2  2  3  3  3
%                       iDyn    1 2 3 4 5 6 7 1 2  3  4  5  6  7  1  2  3
%                       e.g. FullTrajStackData, FullImReconStackData
%
%                       OR
%                       cell(2,1) holding separate arrays to plot, e.g.
%                       coil and probe data, abs and angle images, images
%                       and traj data
%
%   handlePlotFunction  function handle that should point to a function of
%                       the following form:
%                       [fh yMin, yMax] = PlotFunction(Y,iDynSli,fh, yMin,yMax)
%                       where
%                       Y           is the data to be plotted as above
%                       iDynSli     parameter informing that
%                                   Y(:,:,iDynSli) shall be plotted by the function
%                       fh          figure handle where plotting occurs
%                       yMin        ylim(1) - allows for constant scaling
%                                   when movie moves to next frame
%                       yMax        ylim(2)
%
%                       i.e. handlePlotFunction = @PlotFunction
%                       e.g. @plotTrajDiagnostics, @plotCoilDiagnostics
%   nSli                {1} number of different slices in Y %
%                       - only needed, if Y given as 3D matrix, otherwise
%                       3rd dimension assumed to be slices
%
% EXAMPLE
% 1)
%   [Y, absY, angY] = getAbsAngleCoilData(14, 1:92, 23, 17:32, 3)
%   nSli = 1;
%   slider4d({absY angY}, @plotCoilDiagnostics, nSli)
% 2)
%   nSli = 36;
%   slider4d(abs(FullImReconStackData), @plotImageDiagnostics, nSli)
%
%   See also plotTrajDiagnostics plotCoilDiagnostics getAbsAngleCoilData
%
% Author: Lars Kasper
% Created: 2013-01-05
% Copyright 2013 Institute for Biomedical Engineering, ETH/Uni Zurich.
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @slider4d_OpeningFcn, ...
    'gui_OutputFcn',  @slider4d_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before slider4d is made visible.
function slider4d_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to slider4d (see VARARGIN)

% Choose default command line output for slider4d
handles.output = hObject;
set(hObject, 'WindowStyle', 'normal');
handles.y = [];
nSli = 1;

if nargin > 3
    handles.y = varargin{1};
else
    %    handles.y = evalin('base', 'FullKorigStackData');
    handles.y = {evalin('base', 'absY'), evalin('base', 'angY')};
end

if nargin > 4
    handles.fun = varargin{2};
else
    % handles.fun = @plotTrajDiagnostics;
    handles.fun = @plotCoilDiagnostics;
end

if nargin > 5
    nSli = varargin{3};
end

if nargin > 6
    handles.yMin = varargin{4};
else
    handles.yMin = [];
end

if nargin > 7
    handles.yMax = varargin{5};
else
    handles.yMax = [];
end

iDyn = 1;
iSli = 1;

if iscell(handles.y)
    
    nCell = length(handles.y);
    
    for iCell=1:nCell
        if size(handles.y{iCell},4)>1 % 4-dimensional array, separating slices and dyns
            sY = size(handles.y{iCell});
            
            if sY(3) == nSli % 3rd dim slices, swap!
                handles.y{iCell} = permute(handles.y{iCell}, [1 2 4 3]); % make 3rd dimension dynamics, 4th dimension slices
            end
            handles.y{iCell} = reshape(handles.y{iCell},sY(1), sY(2), []);
        end
    end
    nDyn = size(handles.y{1},3)/nSli;
    
else % no cell array
    if size(handles.y,4)>=1 % 4-dimensional array, separating slices and dyns
        sY = size(handles.y);
        if sY(3) == nSli % 3rd dim slices, swap!
            handles.y = permute(handles.y, [1 2 4 3]); % make 3rd dimension dynamics, 4th dimension slices
        end
        handles.y = reshape(handles.y,sY(1), sY(2), []);
    end
    nDyn = size(handles.y,3)/nSli;
end

iDynSli = nDyn*(iSli-1) + iDyn;

handles.outputFigure = figure('Name', 'Video of Diagnostics');

if nSli > 1
    set(handles.slider1, 'Value', 1, 'Min', 1, 'Max', nSli, 'SliderStep', [1 10]./(nSli-1));
else
    set(handles.slider1, 'Enable', 'off');
end
if nDyn > 1
    set(handles.slider2, 'Value', 1, 'Min', 1, 'Max', nDyn, 'SliderStep', [1 10]./(nDyn-1));
else
    set(handles.slider2, 'Enable', 'off');
end
set(handles.text3, 'String', sprintf('of %d', nSli));
set(handles.text4, 'String', sprintf('of %d', nDyn));
set(handles.ScalingAutoCheckbox, 'Value', 1);
handles.nSli = nSli;
handles.nDyn = nDyn;
handles.iSli = iSli;
handles.iDyn = iDyn;
handles.iDynSli = iDynSli;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes slider4d wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = slider4d_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.iSli = round(get(hObject, 'Value'));
set(handles.edit1, 'String', int2str(handles.iSli));
handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
if get(handles.ScalingAutoCheckbox, 'Value')
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
        [], []);
    handles.yMin = handles.yMinOut;
    handles.yMax = handles.yMaxOut;
    % update edit boxes to actual scaling
    set(handles.ScalingMinEdit, 'String', sprintf('%4.1f',handles.yMin(1)));
    set(handles.ScalingMaxEdit, 'String', sprintf('%4.1f',handles.yMax(1)));
else
    % read scaling from edit boxes
    handles.yMin = str2double(get(handles.ScalingMinEdit, 'String'));
    handles.yMax = str2double(get(handles.ScalingMaxEdit, 'String'));
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
        handles.yMin, handles.yMax);
end



figure(handles.figure1);
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.iSli = str2num(get(hObject, 'String'));
set(handles.slider1, 'Value', handles.iSli);
handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
if get(handles.ScalingAutoCheckbox, 'Value')
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure);
    handles.yMin = handles.yMinOut;
    handles.yMax = handles.yMaxOut;
    % update edit boxes to actual scaling
    set(handles.ScalingMinEdit, 'String', sprintf('%4.1f',handles.yMin(1)));
    set(handles.ScalingMaxEdit, 'String', sprintf('%4.1f',handles.yMax(1)));
else
    % read scaling from edit boxes
    handles.yMin = str2double(get(handles.ScalingMinEdit, 'String'));
    handles.yMax = str2double(get(handles.ScalingMaxEdit, 'String'));
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
        handles.yMin, handles.yMax);
end
figure(handles.figure1);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.iDyn = round(get(hObject, 'Value'));
set(handles.edit2, 'String', int2str(handles.iDyn));
handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
if get(handles.ScalingAutoCheckbox, 'Value')
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure);
    handles.yMin = handles.yMinOut;
    handles.yMax = handles.yMaxOut;
    % update edit boxes to actual scaling
    set(handles.ScalingMinEdit, 'String', sprintf('%4.1f',handles.yMin(1)));
    set(handles.ScalingMaxEdit, 'String', sprintf('%4.1f',handles.yMax(1)));
else
    % read scaling from edit boxes
    handles.yMin = str2double(get(handles.ScalingMinEdit, 'String'));
    handles.yMax = str2double(get(handles.ScalingMaxEdit, 'String'));
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
        handles.yMin, handles.yMax);
end
figure(handles.figure1);
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.iDyn = str2num(get(hObject, 'String'));
set(handles.slider2, 'Value', handles.iDyn);
handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
if get(handles.ScalingAutoCheckbox, 'Value')
    handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure);
    handles.yMin = handles.yMinOut;
    handles.yMax = handles.yMaxOut;
    
    % update edit boxes to actual scaling
    set(handles.ScalingMinEdit, 'String', sprintf('%4.1f',handles.yMin(1)));
    set(handles.ScalingMaxEdit, 'String', sprintf('%4.1f',handles.yMax(1)));
else
    % read scaling from edit boxes
    handles.yMin = str2double(get(handles.ScalingMinEdit, 'String'));
    handles.yMax = str2double(get(handles.ScalingMaxEdit, 'String'));
    [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
        handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
        handles.yMin, handles.yMax);
end
figure(handles.figure1);
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1
if get(hObject,'Value')
    iDyn = ceil(get(handles.slider2, 'Value') - 1);
    iSli = ceil(get(handles.slider1, 'Value') - 1);
    
    % loop while "Play Movie" is toggled "on"
    while get(handles.togglebutton1, 'Value')
        switch get(get(handles.uipanel1, 'SelectedObject'), 'String')
            case 'Slice'
                iSli = mod(iSli + 1, handles.nSli);
                handles.iSli = iSli + 1;
            case 'Dynamic'
                iDyn = mod(iDyn + 1, handles.nDyn);
                handles.iDyn = iDyn + 1;
            case 'both'
                if iSli == handles.nSli - 1 % next dynamic !
                    iDyn = mod(iDyn + 1, handles.nDyn);
                    handles.iDyn = iDyn + 1;
                end
                iSli = mod(iSli + 1, handles.nSli);
                handles.iSli = iSli + 1;
                
        end
       set(handles.slider2, 'Value', handles.iDyn);
       set(handles.edit2, 'String', int2str(handles.iDyn));
       set(handles.slider1, 'Value', handles.iSli);
       set(handles.edit1, 'String', int2str(handles.iSli));
        
        handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
        if get(handles.ScalingAutoCheckbox, 'Value')
            handles.iDynSli = handles.nDyn*(handles.iSli-1) + handles.iDyn;
            
            [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
                handles.fun(handles.y, handles.iDynSli, handles.outputFigure);
           
            % speed up via 2D matrix given? => not so far...
            %            [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
            %                handles.fun(handles.y(:,:, handles.iDynSli), 1, handles.outputFigure);
            
            handles.yMin = handles.yMinOut;
            handles.yMax = handles.yMaxOut;
            
            % update edit boxes to actual scaling
            set(handles.ScalingMinEdit, 'String', sprintf('%4.1f',handles.yMin(1)));
            set(handles.ScalingMaxEdit, 'String', sprintf('%4.1f',handles.yMax(1)));
        else
            % read scaling from edit boxes
            handles.yMin = str2double(get(handles.ScalingMinEdit, 'String'));
            handles.yMax = str2double(get(handles.ScalingMaxEdit, 'String'));
         
            [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
                handles.fun(handles.y, handles.iDynSli, handles.outputFigure, ...
                handles.yMin, handles.yMax);
          
            % speed up via 2D matrix given? => not so far...
            %   [handles.outputFigure, handles.yMinOut, handles.yMaxOut] = ...
            %       handles.fun(handles.y(:,:, handles.iDynSli), 1, handles.outputFigure, ...
            %       handles.yMin, handles.yMax);
        end
        
        %figure(handles.figure1);
        drawnow;
%        pause(0.1);
        guidata(hObject, handles);
    end
end


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)



function ScalingMinEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ScalingMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScalingMinEdit as text
%        str2double(get(hObject,'String')) returns contents of ScalingMinEdit as a double


% --- Executes during object creation, after setting all properties.
function ScalingMinEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScalingMinEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ScalingMaxEdit_Callback(hObject, eventdata, handles)
% hObject    handle to ScalingMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ScalingMaxEdit as text
%        str2double(get(hObject,'String')) returns contents of ScalingMaxEdit as a double


% --- Executes during object creation, after setting all properties.
function ScalingMaxEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ScalingMaxEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ScalingAutoCheckbox.
function ScalingAutoCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to ScalingAutoCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ScalingAutoCheckbox
