function varargout = BreathCorrector(varargin)
% BREATHCORRECTOR MATLAB code for BreathCorrector.fig
%      BREATHCORRECTOR, by itself, creates a new BREATHCORRECTOR or raises the existing
%      singleton*.
%
%      H = BREATHCORRECTOR returns the handle to a new BREATHCORRECTOR or the handle to
%      the existing singleton*.
%
%      BREATHCORRECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BREATHCORRECTOR.M with the given input arguments.
%
%      BREATHCORRECTOR('Property','Value',...) creates a new BREATHCORRECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BreathCorrector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BreathCorrector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BreathCorrector

% Last Modified by GUIDE v2.5 21-Apr-2017 11:06:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BreathCorrector_OpeningFcn, ...
    'gui_OutputFcn',  @BreathCorrector_OutputFcn, ...
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


% --- Executes just before BreathCorrector is made visible.
function BreathCorrector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BreathCorrector (see VARARGIN)
%% Loading KWIKfile data.
KWIKfile = varargin{1};
FilesKK = FindFilesKK(KWIKfile);
efd = EFDmaker(KWIKfile);

%% Finding respiration data
[a,b] = fileparts(FilesKK.AIP);
handles.RESPfile = [a,filesep,b,'.resp'];
[~,handles.PREX,~,handles.RRR,~] = resp_loader(handles.RESPfile);
Fs = 2000;
[~,~,~,~,handles.resp,~] = NS3Unpacker(FilesKK.AIP);

handles.Fs = Fs;
handles.Correct = zeros(size(handles.PREX));
handles.ValveTimes = efd.ValveTimes;
handles.t = 1/Fs:1/Fs:length(handles.RRR)/Fs;
handles.V = 1;
handles.T = 1;
handles.B = 0;
handles.plotwin = [-1 2];
AnnotatedBreathPlot(handles);

% Choose default command line output for BreathCorrector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes BreathCorrector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BreathCorrector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.V = str2double(get(hObject,'String'));
AnnotatedBreathPlot(handles);
% Save the handles structure.
guidata(hObject,handles)

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



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.T = str2double(get(hObject,'String'));
AnnotatedBreathPlot(handles);
% Save the handles structure.
guidata(hObject,handles)

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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.x,handles.y] = ginput(1);
display(num2str(handles.x))
currentPREXIndex = handles.ValveTimes.PREXIndex{handles.V}(handles.T)+handles.B;
currentPREX = handles.PREX(currentPREXIndex);
handles.Correct(currentPREXIndex) = currentPREX+handles.x;
handles.PREX(currentPREXIndex) = currentPREX+handles.x;
AnnotatedBreathPlot(handles);
guidata(hObject,handles)




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.x,handles.y] = ginput(1);
display(num2str(handles.x))
currentPREXIndex = handles.ValveTimes.PREXIndex{handles.V}(handles.T)+handles.B;
nextPREXIndex = 1+handles.ValveTimes.PREXIndex{handles.V}(handles.T)+handles.B;
currentPREX = handles.PREX(currentPREXIndex);
handles.Correct(nextPREXIndex) = currentPREX+handles.x;
handles.PREX(nextPREXIndex) = currentPREX+handles.x;
AnnotatedBreathPlot(handles);
guidata(hObject,handles)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[InhTimes,PREX,POSTX,RRR,BbyB] = resp_loader(handles.RESPfile);
PREX = handles.PREX;
Correct = handles.Correct;
save(handles.RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB','Correct')
close(gcf);
%
% function [] = fh_kpfcn(H,E)
% % Figure keypressfcn
% S = guidata(H);
% P = get(S.fh,'position');
% set(S.tx,'string',E.Key)
% switch E.Key
%     case 'rightarrow'
%         set(S.fh,'pos',P+[5 0 0 0])
%     case 'leftarrow'
%         set(S.fh,'pos',P+[-5 0 0 0])
%     case 'uparrow'
%         set(S.fh,'pos',P+[0 5 0 0])
%     case 'downarrow'
%         set(S.fh,'pos',P+[0 -5 0 0])
%     otherwise
% end




% --- Executes during object creation, after setting all properties.
function pushbutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function pushbutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function pushbutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% Figure keypressfcn
S = guidata(hObject);
P = get(S.figure1,'position');
% set(S.tx,'string',eventdata.Key)
switch eventdata.Key
    case 'rightarrow'
        if handles.T <length(handles.ValveTimes.PREXIndex{handles.V})
            handles.T = handles.T + 1;
            set(handles.edit2,'String',num2str(handles.T));
            
            AnnotatedBreathPlot(handles);
            % Save the handles structure.
            guidata(hObject,handles)
        end
    case 'leftarrow'
        if handles.T > 1
            handles.T = handles.T - 1;
            set(handles.edit2,'String',num2str(handles.T));
            AnnotatedBreathPlot(handles);
            % Save the handles structure.
            guidata(hObject,handles)
        end
    case 'uparrow'
        set(S.figure1,'pos',P+[0 5 0 0])
    case 'downarrow'
        set(S.figure1,'pos',P+[0 -5 0 0])
    otherwise
end

