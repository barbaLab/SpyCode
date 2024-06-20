function varargout = ComputeThresholdGUI(varargin)
% COMPUTETHRESHOLDGUI M-file for ComputeThresholdGUI.fig
%      COMPUTETHRESHOLDGUI, by itself, creates a new COMPUTETHRESHOLDGUI or raises the existing
%      singleton*.
%
%      H = COMPUTETHRESHOLDGUI returns the handle to a new COMPUTETHRESHOLDGUI or the handle to
%      the existing singleton*.
%
%      COMPUTETHRESHOLDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPUTETHRESHOLDGUI.M with the given input arguments.
%
%      COMPUTETHRESHOLDGUI('Property','Value',...) creates a new COMPUTETHRESHOLDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ComputeThresholdGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ComputeThresholdGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ComputeThresholdGUI

% Last Modified by GUIDE v2.5 24-Mar-2010 15:44:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ComputeThresholdGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ComputeThresholdGUI_OutputFcn, ...
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


% --- Executes just before ComputeThresholdGUI is made visible.
function ComputeThresholdGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ComputeThresholdGUI (see VARARGIN)

% Choose default command line output for ComputeThresholdGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% ------------> VARIABLES
handles.exp_num      = varargin {1}; % Experiment number
handles.phase_folder = varargin {2}; % Folder containing the experiment files - 1 phase
handles.exp_folder   = varargin {3}; % folder for saving threshold vector - experiment folder
handles.output       = [];           % Output of the function

% Other variables
handles.nstd           = 8;      % std multiplication factor
handles.fs             = 10000;  % sampling frequency
handles.chSelecCounter = 0;      % used to track how many times the user selects the channel popupmenu
handles.tollerance     = 0.30;   % tolerance for test control
handles.relevance      = 0.0001; % relevance for test control
handles.controlling    = 0;
handles.t1   = [];
handles.t2   = [];
handles.l1   = [];
handles.l2   = [];

% INTERFACE INITIALIZATION
set(handles.EditSamplFrequency, 'String', '10000');
contents = get(handles.PopUpMenuStdTime,'String');
set (handles.PopUpMenuStdTime, 'Value', strmatch('8', contents, 'exact'));

set(handles.EditXlimINF, 'String', '0');
set(handles.EditXlimSUP, 'String', '300');
set(handles.EditYlimINF, 'String', '0');
set(handles.EditYlimSUP, 'String', '100');

set(handles.AcceptButton,           'Enable', 'off');
set(handles.CalculateThresh,        'Enable', 'off');
set(handles.ActivateCursorsTbutton, 'Enable', 'off');
set(allchild(handles.ChannelPanel), 'Enable', 'off');
set(handles.CheckControlTest,'Value', 1); % the check is '1' as default
set(findobj('-regexp','Tag','Toggle.*'), 'Value', 0); % Electrodes' toggle buttons are deselected

% We make hypothesis that the selected MEA is MCS - for MED64-->ToBeImplemented
handles.ChNum = 60;
handles.MEAElectrodes = [(12:17)'; (21:28)'; (31:38)'; (41:48)'; (51:58)'; (61:68)'; (71:78)';(82:87)'];
handles.thresh_vector = zeros(87,1);

set(handles.Toggle11, 'Visible', 'off'); % Hide the electrode's toggle button
set(handles.Toggle18, 'Visible', 'off'); % Hide the electrode's toggle button
set(handles.Toggle81, 'Visible', 'off'); % Hide the electrode's toggle button
set(handles.Toggle88, 'Visible', 'off'); % Hide the electrode's toggle button
set(handles.Text11, 'Visible', 'off'); % Hide the electrode's text
set(handles.Text18, 'Visible', 'off'); % Hide the electrode's text
set(handles.Text81, 'Visible', 'off'); % Hide the electrode's text
set(handles.Text88, 'Visible', 'off'); % Hide the electrode's text

% PopUpMenuSelectCh must be changed according to the chosen MEA
contents = get(handles.PopUpMenuSelectCh,'String');
% [2 9 58 65] are the indexes of electrodes 11, 18, 81, 88
contents([2 9 58 65])=[];
set(handles.PopUpMenuSelectCh,'String', contents);

% ------------> FOLDER MANAGEMENT
% The folder of the first experimental phase is the default one. If the user wants to
% change it, he has to browse for the correct folder
cd(handles.phase_folder);% Luca
set(handles.TextDispFolder, 'String', handles.phase_folder);

guidata(hObject, handles);
% UIWAIT makes ComputeThresholdGUI wait for user response (see UIRESUME)
uiwait(handles.ComputeThresholdFigure);



% --- Outputs from this function are returned to the command line.
function varargout = ComputeThresholdGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
guidata(hObject, handles);
varargout{1} = handles.output;

delete(hObject);


% --- Executes when user attempts to close ComputeThresholdFigure.
function ComputeThresholdFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ComputeThresholdFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ~strcmpi(get(hObject,'waitstatus'),'waiting')
    delete(hObject);
    return;
end
uiresume


%%%%%%%%%%%%%%%%%%%%%%  BROWSE FOLDER  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in BrowseExpPhase.
function BrowseExpPhase_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseExpPhase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

InputMessage = 'Select the folder containing the MAT files of one experimental phase';
phase_folder = uigetdir(handles.phase_folder, InputMessage);

if  (phase_folder == 0)
    errordlg('Selection Failed - Folder does not exists', 'Error');
    set(handles.TextDispFolder, 'String', 'Single Experiment Phase - Raw Data MAT files');
else
    set(handles.TextDispFolder, 'String', phase_folder);
    handles.phase_folder = phase_folder;
end

% Initial conditions of the GUI must be restored
cla(handles.RawDataAxes)
contents = get(handles.PopUpMenuSelectCh,'String');
set (handles.PopUpMenuSelectCh, 'Value', strmatch('-- select channel --', contents));
set(handles.EditXlimINF, 'String', '0');
set(handles.EditXlimSUP, 'String', '300');
set(handles.EditYlimINF, 'String', '0');
set(handles.EditYlimSUP, 'String', '100');

contents = get(handles.PopUpMenuStdTime,'String');
set (handles.PopUpMenuStdTime, 'Value', strmatch('8', contents, 'exact'));
set(handles.EditSamplFrequency, 'String', '10000');
handles.nstd = 8;      % std multiplication factor
handles.fs   = 10000;  % sampling frequency

guidata(hObject, handles); % Update the handles structure


%%%%%%%%%%%%%%%%%%%%%%  GRAPH OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in PopUpMenuSelectCh.
function PopUpMenuSelectCh_Callback(hObject, eventdata, handles)
% hObject    handle to PopUpMenuSelectCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns PopUpMenuSelectCh contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopUpMenuSelectCh

% control if a channel is selected
if get(hObject,'Value') == 1 % If the first element is selected ('no selection')
    cla                      % No raw data is plotted
    text(60,0,'Raw Data Channel Not Present')
else
    found = 1;
    set(handles.ActivateCursorsTbutton, 'Enable', 'on');
    cd(handles. phase_folder);

    content   = dir;
    handles.content = content;
    selection = get(hObject,'Value') - 1; % it gives the number of selection from the pop-up menu
    selection = handles.MEAElectrodes(selection); % convert to the correspondant electrode
    handles.SelectedElectrode = selection;

    % search for the electrode selected
    for i=3:length(content)
        tryfile = content(i).name;
        % if found, exit
        if strcmp(tryfile(end-5:end-4),num2str(selection)), break, end
        % otherwise impost found to 0
        if i == length(content), found = 0; end
    end

    if ~found % if not found, print text on figure
        cla
        text(60,0,'raw data channel not present')
    else % otherwise plot the raw data
        handles.chSelecCounter=handles.chSelecCounter+1;

        filename = content(i).name;
        load(filename);
        x=[1:length(data)]/handles.fs;
        plot(handles.RawDataAxes, x, data);

        % Axis limits
        xlimINF = 0;
        xlimSUP = length(data)/handles.fs;
        ylimINF = min(data);
        ylimSUP = max(data);
        axis([xlimINF xlimSUP ylimINF ylimSUP])
        % Update boxes in the GUI
        set(handles.EditXlimINF, 'String', xlimINF);
        set(handles.EditXlimSUP, 'String', xlimSUP);
        set(handles.EditYlimINF, 'String', ylimINF);
        set(handles.EditYlimSUP, 'String', ylimSUP);

        %if during controlling print again previous range selected
        if handles.controlling  || isfield(handles,'pos1') %luca
            pos1 = handles.pos1;
            pos2 = handles.pos2;
            val1=num2str(round(pos1(1,1)));
            handles.t1=text(pos1(1,1),pos1(1,2),val1,'FontSize',18,'Color','r');
            y=ylim;
            handles.l1=line([pos1(1,1),pos1(1,1)],[y(1),y(2)],'Color','r');
            val2=num2str(round(pos2(1,1)));
            handles.t2=text(pos2(1,1),-pos2(1,2),val2,'FontSize',18,'Color','r');
            handles.l2=line([pos2(1,1),pos2(1,1)],[y(1),y(2)],'Color','r');
        end %luca
    end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PopUpMenuSelectCh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUpMenuSelectCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditXlimINF_Callback(hObject, eventdata, handles)
% hObject    handle to EditXlimINF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of EditXlimINF as text
%        str2double(get(hObject,'String')) returns contents of EditXlimINF as a double

xlim([str2double(get(hObject,'String')) str2double(get(handles.EditXlimSUP,'String'))])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditXlimINF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXlimINF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditXlimSUP_Callback(hObject, eventdata, handles)
% hObject    handle to EditXlimSUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of EditXlimSUP as text
%        str2double(get(hObject,'String')) returns contents of EditXlimSUP as a double

xlim([str2double(get(handles.EditXlimINF,'String')) str2double(get(hObject,'String'))])
guidata(hObject, handles);
t
% --- Executes during object creation, after setting all properties.
function EditXlimSUP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditXlimSUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditYlimINF_Callback(hObject, eventdata, handles)
% hObject    handle to EditYlimINF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of EditYlimINF as text
%        str2double(get(hObject,'String')) returns contents of EditYlimINF as a double

ylim([str2double(get(hObject,'String')) str2double(get(handles.EditYlimSUP,'String'))])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditYlimINF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYlimINF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditYlimSUP_Callback(hObject, eventdata, handles)
% hObject    handle to EditYlimSUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of EditYlimSUP as text
%        str2double(get(hObject,'String')) returns contents of EditYlimSUP as a double

ylim([str2double(get(handles.EditYlimINF,'String')) str2double(get(hObject,'String'))])
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditYlimSUP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditYlimSUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PushZoomIn.
function PushZoomIn_Callback(hObject, eventdata, handles)
% hObject    handle to PushZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom on
guidata(hObject, handles);

% this part of the code does not work ...
xlimFromAxes = get(gca, 'xlim');
ylimFromAxes = get(gca, 'ylim');
set(handles.EditXlimINF, 'String', xlimFromAxes (1));
set(handles.EditXlimSUP, 'String', xlimFromAxes (2));
set(handles.EditYlimINF, 'String', ylimFromAxes (1));
set(handles.EditYlimSUP, 'String', ylimFromAxes (2));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PushZoomIn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PushZoomIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in PushZoomOut.
function PushZoomOut_Callback(hObject, eventdata, handles)
% hObject    handle to PushZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom off
zoom (0.25)
guidata(hObject, handles);

xlimFromAxes = get(gca, 'xlim');
ylimFromAxes = get(gca, 'ylim');
set(handles.EditXlimINF, 'String', xlimFromAxes (1));
set(handles.EditXlimSUP, 'String', xlimFromAxes (2));
set(handles.EditYlimINF, 'String', ylimFromAxes (1));
set(handles.EditYlimSUP, 'String', ylimFromAxes (2));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PushZoomOut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PushZoomOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



%%%%%%%%%%%%%%%%%%%%%%  SELECT THRESHOLD OPTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in PopUpMenuStdTime.
function PopUpMenuStdTime_Callback(hObject, eventdata, handles)
% hObject    handle to PopUpMenuStdTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns PopUpMenuStdTime contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PopUpMenuStdTime

contents     = get(hObject,'String');
handles.nstd = str2num(contents{get(hObject,'Value')});

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PopUpMenuStdTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PopUpMenuStdTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function EditSamplFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to EditSamplFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of EditSamplFrequency as text
%        str2double(get(hObject,'String')) returns contents of EditSamplFrequency as a double

handles.fs = str2double(get(hObject,'String')) ;

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function EditSamplFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditSamplFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in ActivateCursorsTbutton.
function ActivateCursorsTbutton_Callback(hObject, eventdata, handles)
% hObject    handle to ActivateCursorsTbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ActivateCursorsTbutton

% Initialization of the GUI, preparing for range selection
if ~isempty(handles.t1)
    delete(handles.t1);
    delete(handles.t2);
    delete(handles.l1);
    delete(handles.l2);
end

% This part could be better written...
if handles.controlling
    %     handles.controlling = 0;
    for k=1:length(handles.MEAElectrodes)
        h = ['handles.Toggle' num2str(handles.MEAElectrodes(k))];
        if ~get(eval(h),'Value')
            set(eval(h),'ForegroundColor','black','String','0');
        end
    end
end

% Check the status of the togglebutton
if get(hObject,'Value') % ACTIVATE CURSORS
    
    set (handles.CalculateThresh, 'Enable', 'on') % Calculate Threshold is enabled    
    set(hObject, 'String', 'Deactivate Cursors');
    zoom off
    delete (findall(gcf,'type', 'annotation'));
    set (allchild(handles.PanelGraphOptions), 'Enable', 'off');
    %set(allchild(handles.PanelGraphOptions), 'Enable', 'off');
    set (handles.BrowseExpPhase, 'Enable', 'off')
    
    set(gcf,'Pointer','crosshair'); % Cursors are activated
    
    % Select range for calculating thresholds
    % FIRST pointer
    waitforbuttonpress;
    pos1 = get(gca,'currentpoint');
    handles.pos1 = pos1;
    val1=num2str(round(pos1(1,1)));
    handles.t1 = text(pos1(1,1),pos1(1,2),val1,'FontSize',18,'Color','r');
    y=ylim;
    handles.l1 = line([pos1(1,1),pos1(1,1)],[y(1),y(2)],'Color','r');
    
    % SECOND pointer
    waitforbuttonpress;
    pos2 = get(gca,'currentpoint');
    handles.pos2 = pos2;
    val2=num2str(round(pos2(1,1)));
    handles.t2 = text(pos2(1,1),-pos2(1,2),val2,'FontSize',18,'Color','r');
    handles.l2 = line([pos2(1,1),pos2(1,1)],[y(1),y(2)],'Color','r');

    set(gcf,'Pointer','arrow'); % Cursors are de-activated

else % DE-ACTIVATE CURSORS
    set (handles.CalculateThresh, 'Enable', 'off') % Calculate Threshold is not enabled
    set(hObject, 'String', 'Activate Cursors');
    set(gcf,'Pointer', 'arrow'); % Cursors are de-activated
    set(allchild(handles.PanelGraphOptions), 'Enable', 'on');
    set (handles.BrowseExpPhase, 'Enable', 'on')

    handles.t1   = [];
    handles.t2   = [];
    handles.l1   = [];
    handles.l2   = [];
end

guidata(hObject, handles);



% --- Executes on button press in CalculateThresh.
function CalculateThresh_Callback(hObject, eventdata, handles)
% hObject    handle to CalculateThresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- START COMPUTING THRESHES --- %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
content = handles.content;

if get(handles.CheckControlTest, 'Value') % if control test is activated...
    for k = 3:length(content)
        tryfile = content(k).name;
        % ...search for the file visualized...
        if strcmp(tryfile(end-5:end-4),num2str(handles.SelectedElectrode))
            load(content(k).name); % variable data is loaded here
            data = data - mean(data);
            data_win=data(50*handles.fs + 1:100*handles.fs,1);
            %data_win=data(round(min(handles.pos1(1,1),handles.pos2(1,1))*handles.fs):round(max(handles.pos1(1,1),handles.pos2(1,1))*handles.fs),1);
            thresh = handles.nstd*std(data_win);
            handles.thresh_vector(handles.SelectedElectrode)= thresh;  %...store thresh...
            warning = max(abs(data_win));              %...and a parameter for the control test
            
            break
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


w = waitbar(0,'Computing thresholds - Please wait...'); % waitbar

% cycle on all the files for thresh calculation
for i = 3:length(content)
    waitbar((i-2)/length(content))
    % k is referred to the raw data found and already computed above
    if get(handles.CheckControlTest,'Value') && (i == k), continue, end
    filename = content(i).name;
    electrode=filename(end-5:end-4);  
    h = ['handles.Toggle',electrode];
    % if button referred to this electrode is pushed, it continues without
    % recalculate the thresh
    if get(eval(h),'Value'), continue, end
    load (filename);
    data = data-mean(data);  
    data_win=data(50*handles.fs + 1:100*handles.fs,1); %from 50s to 100s
    %data_win=data(round(min(handles.pos1(1,1),handles.pos2(1,1))*handles.fs):round(max(handles.pos1(1,1),handles.pos2(1,1))*handles.fs),1);
    
    % control test
    if get(handles.CheckControlTest,'Value')
       if length(find(abs(data_win) > (warning + warning*handles.tollerance))) > handles.relevance*length(data_win)
          aa = handles.relevance;
          bb = handles.tollerance;
          handles.controlling = 1;
          h = ['handles.Toggle',electrode];
          set(eval(h),'ForegroundColor','red'); % set the text color of the considered electrode to red
       end
    end
    thresh = handles.nstd*std(data_win);
    handles.thresh_vector(eval(electrode))= thresh; % vector cointaining threshold values
end
close(w)

% to be improved
visualize = (round(handles.thresh_vector*10))/10; % visualize aproximated values
for i=1:length(handles.MEAElectrodes)
    h = ['handles.Toggle' num2str(handles.MEAElectrodes(i))];
    set(eval(h),'String',num2str(visualize(handles.MEAElectrodes(i))));
end

% Update the GUI properly
set(allchild(handles.ChannelPanel), 'Enable', 'on');
set(handles.AcceptButton,           'Enable', 'on');
set(handles.CalculateThresh,        'Enable', 'off');
set(handles.ActivateCursorsTbutton, 'Value', 0);
set(handles.ActivateCursorsTbutton, 'String', 'Activate Cursors');
set(allchild(handles.PanelGraphOptions), 'Enable', 'on');

handles.t1   = [];
handles.t2   = [];
handles.l1   = [];
handles.l2   = [];

guidata(hObject, handles);


% --- Executes on button press in CheckControlTest.
function CheckControlTest_Callback(hObject, eventdata, handles)
% hObject    handle to CheckControlTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of CheckControlTest


% --- Executes on button press in SelectAll.
function SelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to SelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(findobj('-regexp','Tag','Toggle.*'), 'Value', 1);


% --- Executes on button press in DeselectAll.
function DeselectAll_Callback(hObject, eventdata, handles)
% hObject    handle to DeselectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(findobj('-regexp','Tag','Toggle.*'), 'Value', 0);



%%%%%%%%%%%%%%%%%%%%%%  SAVING & QUITTING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% --- Executes on button press in AcceptButton.
function AcceptButton_Callback(hObject, eventdata, handles)
% hObject    handle to AcceptButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cd (handles.exp_folder);
thresh_filename = strcat (handles.exp_num, '_', 'thresh_vectorfile.mat');
thresh_vector = handles.thresh_vector;
save(thresh_filename,'thresh_vector');
handles.output = thresh_filename;
guidata(hObject, handles);

close(handles.ComputeThresholdFigure)
% uiresume;




% --- Executes on button press in QuitButton.
function QuitButton_Callback(hObject, eventdata, handles)
% hObject    handle to QuitButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close(handles.ComputeThresholdFigure)



%%%%%%%%%%%%%%%%%%%%%%  ELECTRODES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% --- Executes on button press in Toggle11.
function Toggle11_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle11

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle12.
function Toggle12_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle12

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle13.
function Toggle13_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle13

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle14.
function Toggle14_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle14

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle15.
function Toggle15_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle15

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle16.
function Toggle16_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle16

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle17.
function Toggle17_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle17

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle18.
function Toggle18_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle18

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle21.
function Toggle21_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle21

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle22.
function Toggle22_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle22

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle23.
function Toggle23_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle23

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle24.
function Toggle24_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle24

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle25.
function Toggle25_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle25

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle26.
function Toggle26_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle26

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle27.
function Toggle27_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle27

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle28.
function Toggle28_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle28

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle31.
function Toggle31_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle31

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle32.
function Toggle32_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle32

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle33.
function Toggle33_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle33

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle34.
function Toggle34_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle34

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle35.
function Toggle35_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle35

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle36.
function Toggle36_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle36

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle37.
function Toggle37_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle37

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle38.
function Toggle38_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle38

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle41.
function Toggle41_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle41

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle42.
function Toggle42_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle42 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle42

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle43.
function Toggle43_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle43 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle43

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle44.
function Toggle44_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle44 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle44

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle45.
function Toggle45_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle45 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle45

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle46.
function Toggle46_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle46 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle46

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle47.
function Toggle47_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle47

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle48.
function Toggle48_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle48 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle48

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle51.
function Toggle51_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle51 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle51

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle52.
function Toggle52_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle52 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle52

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle53.
function Toggle53_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle53 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle53

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle54.
function Toggle54_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle54 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle54

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle55.
function Toggle55_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle55 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle55

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle56.
function Toggle56_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle56 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle56

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle57.
function Toggle57_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle57 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle57

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle58.
function Toggle58_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle58 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle58

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle61.
function Toggle61_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle61

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle62.
function Toggle62_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle62

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle63.
function Toggle63_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle63

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle64.
function Toggle64_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle64 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle64

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle65.
function Toggle65_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle65

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle66.
function Toggle66_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle66

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle67.
function Toggle67_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle67 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle67

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle68.
function Toggle68_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle68 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle68

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle71.
function Toggle71_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle71 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle71

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle72.
function Toggle72_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle72 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle72

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle73.
function Toggle73_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle73 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle73

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle74.
function Toggle74_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle74 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle74

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle75.
function Toggle75_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle75

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle76.
function Toggle76_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle76 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle76

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle77.
function Toggle77_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle77 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle77

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle78.
function Toggle78_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle78 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle78

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle81.
function Toggle81_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle81 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle81

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle82.
function Toggle82_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle82 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle82

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle83.
function Toggle83_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle83

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle84.
function Toggle84_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle84 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle84

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle85.
function Toggle85_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle85 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle85

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle86.
function Toggle86_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle86 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle86

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle87.
function Toggle87_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle87 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle87

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in Toggle88.
function Toggle88_Callback(hObject, eventdata, handles)
% hObject    handle to Toggle88 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Toggle88

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





