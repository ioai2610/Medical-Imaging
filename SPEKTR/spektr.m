function varargout = spektr(varargin)
%%**************************************************************************
%% System name:      SPEKTR
%% Module name:      spektr.m
%% Version number:   3
%% Revision number:  00
%% Revision date:    15-Jun-2016
%%
%% 2016 (C) Copyright by Jeffrey H. Siewerdsen.
%%          I-STAR Lab
%%          Johns Hopkins University
%%
%%  Usage: spektr
%%
%%  Inputs:
%%
%%  Outputs:
%%
%%  Description:
%%
%%  Notes:
%%
%%*************************************************************************
%% References: 
%%
%%*************************************************************************
%% Revision History
%%  0.000    2003 05 01     AW  Initial code
%%	1.000    2004 03 15     DJM Initial released version
%%  3.000    2015 06 15     JGP Automatic window resize and
%%                              display of inherent filtration
%%*************************************************************************
%%

% SPEKTR M-file for spektr.fig
%      SPEKTR, by itself, creates a new SPEKTR or raises the existing
%      singleton*.
%
%      H = SPEKTR returns the handle to a new SPEKTR or the handle to
%      the existing singleton*.
%
%      SPEKTR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPEKTR.M with the given input arguments.
%
%      SPEKTR('Property','Value',...) creates a new SPEKTR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spektrOpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spektrOpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spektr

% Last Modified by GUIDE v2.5 27-May-2016 08:36:35
% 
global q
global comp_string
global comp_thickness
global element_list
global mu_compound
global filter_list
global filter_list_comp

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spektrOpeningFcn, ...
                   'gui_OutputFcn',  @spektrOutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before spektr is made visible.
function spektrOpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spektr (see VARARGIN)
global filter_list
global filter_list_comp
global q;
global q0;

% Choose default command line output for spektr
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize the filter variables
filter_list = [];
filter_list_comp = [];

% Initialize both spectrum variables
q0 = [];

% UIWAIT makes spektr wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Put the axis property "hold on" by default
set(handles.figure1, 'units', 'normalized', 'position', [0.05 0.15 0.85 0.85])
hold on;

% --- Outputs from this function are returned to the command line.
function varargout = spektrOutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q % x-ray energy spectrum
global q0 % initial x-ray energy spectrum before added filtration
global filter_list
global filter_list_comp
global element_list
global mu_compound


% set the program state to busy
set(handles.edit14,'String','BUSY','ForegroundColor','red');

% refresh screen
drawnow;

% initialize the filter lists
%filter_list = [];
%filter_list_comp = [];

% X-Ray tube settings

% Extract kVp
kVp = str2double(get(handles.edit18,'string'));

% Extract kVRipple
kVRipple = str2double(get(handles.edit2,'string'));

% Extract mm Cu
CuFilterThick = str2double(get(handles.edit26,'string'));

% Extract mm Al
AlFilterThick = str2double(get(handles.edit3,'string'));

% Generate x-ray spectrum
set(gcf, 'DoubleBuffer', 'on');
if get(handles.radiobutton1, 'Value') == 1
    q = spektrSpectrum(kVp,[AlFilterThick kVRipple],'TASMICS', 1);
    q = spektrBeers(q, [29 CuFilterThick]);
else
    q = spektrSpectrum(kVp, [AlFilterThick kVRipple], 'TASMIP');
    q = spektrBeers(q, [29 CuFilterThick]);
end

% Tube Select
hObject = findobj('Tag','popupmenu2');
val = get(hObject,'Value');
string_list = get(hObject,'String');
tube_select = (string_list{val}); % convert from cell array to string
inherent_filter = tubeSettings(tube_select);
q = spektrBeers(q, inherent_filter);

% set the program state to ready
set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

%color handling of plot
hObject = findobj('Tag','popupmenu1');
val = get(hObject,'Value');
string_list = get(hObject,'String');
selected_string = (string_list{val}); % convert from cell array to string
color = selected_string;

%Plot x-ray spectrum

plot(q,color);
xlabel('Energy (keV)');
string = sprintf('Photons / mm^2 / mAs \n at 100cm from the source');
ylabel(string);
title('X-Ray Spectrum');
grid on;

% Store Initial spectrum for reset if desired
q0 = q;

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global AlThick
set(hObject, 'String', '2.5');

AlThick = str2double(get(hObject,'String'));

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
global AlThick
global CuThick;

AlThick = str2double(get(hObject, 'String'));

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

if (get(hObject,'Value') == get(hObject,'Max'))
    % then checkbox is checked-take approriate action
    hold on;
else
    % checkbox is not checked-take approriate action
    hold off;
end


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% % --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% % hObject    handle to popupmenu1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from popupmenu1

% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2

global AlThick;
global CuThick;
string_list = get(hObject, 'String');
val = get(hObject, 'Value'); 
tube_selected = string_list{val};

tubeFilters = tubeSettings(tube_selected);

filters = spektrInherentFiltrationDisplay(tubeFilters);

hObject = findobj('Tag', 'listbox8');
set(hObject, 'String', filters(:, 1));

hObject = findobj('Tag', 'listbox9');
set(hObject, 'String', filters(:, 2));

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

exposure = spektrExposure(q);
set(handles.edit4,'String',num2str(exposure));

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double



% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

%Extract HVL scheme
hObject = findobj('Tag','popupmenu3');
val = get(hObject,'Value');
string_list = get(hObject,'String');
selected_string = (string_list{val}); % convert from cell array to string

%Extract which element to calculate HVL for
hObject2 = findobj('Tag','popupmenu4');
val2 = get(hObject2,'Value');
string_list2 = get(hObject2,'String');
selected_string2 = (string_list2{val2}); % convert from cell array to string
atomic_number = spektrElement2Z(selected_string2);

if strcmp(selected_string,'HVL1')==1
    h = spektrHVLn(q,1,atomic_number);
elseif strcmp(selected_string,'HVL2')==1
    h = spektrHVLn(q,2,atomic_number);        
elseif strcmp(selected_string,'HVL3')==1
    h = spektrHVLn(q,3,atomic_number);        
elseif strcmp(selected_string,'TVL')==1
    h = spektrHVLn(q,log(10)/log(2),atomic_number);
else
    ;
end

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);
set(handles.edit5,'String',num2str(h));

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupmenu4


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;
exposure = spektrExposure(q)/4;
set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);
set(handles.edit6,'String',num2str(exposure));

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;
q = spektrNormalize(q);
set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

%color handling of plot
hObject = findobj('Tag','popupmenu1');
val = get(hObject,'Value');
string_list = get(hObject,'String');
selected_string = (string_list{val}); % convert from cell array to string
color = selected_string;

plot(q,color);
xlabel('Energy (keV)');
string = sprintf('Photons / mm^2 / mAs\n at 100cm from the source');
ylabel(string);
title('X-Ray Spectrum');
grid on;

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add filter to filter list

global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

set(handles.edit14,'String','BUSY');
set(handles.edit14,'ForegroundColor','red');
drawnow;

%filter materials from listbox
hObject = findobj('Tag','listbox2');
val = get(hObject,'Value');
string_list = get(hObject,'String');
filter_to_add = strtok((string_list{val})); % convert from cell array to string

%filter materials from listbox
thickness = str2double(get(handles.edit7,'string'));

% Add filter materials to filter list
if size(filter_list,1) == 0
    filter_list(1,1) = spektrElement2Z(filter_to_add);
    filter_list(1,2) = thickness;
    row = 1;
else
    row = size(filter_list,1);
    row = row+1;
    filter_list(row,1) = spektrElement2Z(filter_to_add);
    filter_list(row,2) = thickness;
end

% Generate Element Filter List [Z thickness;.. ..;.. ..];

list = '';

for j=1:size(filter_list,1),
    temp = strcat('(Z=',num2str(filter_list(j,1)),')__',num2str(filter_list(j,2)),'mm');
    if j==1 
        list = temp;
    else
        list = strvcat(list,temp);
    end    
end

if size(filter_list_comp,1)==0
    ;
else
    % Generate Filter Compound List [C thickness;.. ..;.. ..]
    for i=1:size(filter_list_comp,1),
        temp = strcat('(C=',num2str(filter_list_comp(i,1)),')__',num2str(filter_list_comp(i,2)),'mm');
        list = strvcat(list,temp);
    end
end

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if generate_compound_exists==1
    if comp_thickness==0
        ;
    else
        temp = strcat('New.Comp','_',num2str(comp_thickness),'mm');
        list = strvcat(list,temp);
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
% ADDED
set(handles.listbox3,'String',list);

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

    
% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove filter from list

global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

%filter materials from listbox
val3 = get(handles.listbox3,'Value');
row_to_delete = val3;

if row_to_delete==0 | isempty(filter_list) | row_to_delete>size(filter_list,1)
    ;
else
    % Delete the filter of interest
    filter_list(row_to_delete,:) = [];
end

% Generate the listing of filters/thicknesses in the listbox3
list = [];

% Generate elemental filter list
for j=1:size(filter_list,1),
    temp = strcat('(Z=',num2str(filter_list(j,1)),')__',num2str(filter_list(j,2)),'mm');
    if j==1
        list = temp;
    else
        list = strvcat(list,temp);
    end    
end

% Generate compound filter list
if size(filter_list_comp,1)==0
    ;
else
    for i=1:size(filter_list_comp,1),
        temp = strcat('(C=',num2str(filter_list_comp(i,1)),')__',num2str(filter_list_comp(i,2)),'mm');
        list = strvcat(list,temp);
    end
end

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if generate_compound_exists==1
    if comp_thickness==0
        ;
    else
        temp = strcat('New.Comp','_',num2str(comp_thickness),'mm');
        list = strvcat(list,temp);
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ADDED
%list = strvcat(list,' ');
set(handles.listbox3,'String',list);
selection = get(handles.listbox3,'Value');
if selection > size(list,1) & size(list,1)>0
    set(handles.listbox3,'Value',size(list,1))
end

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Added Filtration

global q % [x-ray spectra]
global q0 % [x-ray spectra]
global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

% Reset Spectrum to initial conditions
q = q0;

if size(q,1)==0
    h = msgbox('Must generate an x-ray spectrum to filter.');
else
    for i=1:size(filter_list,1),
        q = spektrBeers(q,[filter_list(i,1) filter_list(i,2)]);
    end

    for i=1:size(filter_list_comp,1),
        q = spektrBeersCompoundsNIST(q,{filter_list_comp(i,1) filter_list_comp(i,2)});
    end
end

if generate_compound_exists==1
    q = q.*exp(-mu_compound/10*comp_thickness);
end

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

%color handling of plot
hObject = findobj('Tag','popupmenu1');
val = get(hObject,'Value');
string_list = get(hObject,'String');
selected_string = (string_list{val}); % convert from cell array to string
color = selected_string;

%Plot x-ray spectrum
plot(q,color);
xlabel('Energy (keV)');
string = sprintf('Photons / mm^2 / mAs\n at 100cm from the source');
ylabel(string);
title('X-Ray Spectrum');
grid on;


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
% contents = get(hObject,'String');
% selection = get(hObject,'Value');
% last_selection = size(contents,1);
% if selection > last_selection
%     set(hObject,'Value',last_selection)
% end

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

EnergyVector = [1:1:150]';
data_SAVE = [EnergyVector q];

% write data to file
file_SAVE = uiputfile('*.txt', 'Save Spectral Data');
if ~isequal(file_SAVE, 0)
    fid = fopen(file_SAVE,'wt');
    for i=1:150,
        fprintf(fid,'%d   %d\n',data_SAVE(i,1),data_SAVE(i,2));
    end
    string_list = get(handles.popupmenu2, 'String');
    val = get(handles.popupmenu2, 'Value');
    tubeName = string_list{val};
    fprintf(fid,'\n%s:\n%s\n','tube name', tubeName);
    if (get(handles.radiobutton1, 'Value') == 1)
        model_used = 'TASMICS';
    else 
        model_used = 'TASMIP';
    end
    fprintf(fid, '\n%s:\n%s\n','Model Used:', model_used);
    fprintf(fid,'\n%s:\n%s\n','kVp', get(handles.edit18,'String'));
    fprintf(fid,'\n%s:\n%s\n', 'kV Ripple', get(handles.edit2, 'String'));
    fprintf(fid, '\n%s:\n%s\n', 'mm Cu', get(handles.edit26, 'String'));
    fprintf(fid, '\n%s:\n%s\n', 'mm Al', get(handles.edit3,'String'));
    
    added_filters = get(handles.listbox3, 'String');
    fprintf(fid, '\n%s\n', 'Added Filtration:');
    for i = 1:size(added_filters,1)
        fprintf(fid, '%s\n', added_filters(i, :));
    end
    
fclose(fid);
end

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load in spectral data
% format to read in is the following [EnergyVector   q; ...]

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound
global AlThick
global CuThick

% imported data from file
data_LOAD(150:2)=0;

% write data to file
file_LOAD_name = uigetfile('*.txt', 'Select text file containing spectral data');
if ~isequal(file_LOAD_name, 0)
    fid = fopen(file_LOAD_name,'r');
    %Read in q
    data_LOAD = fscanf(fid,'%f %f',[2 150]);
    data_LOAD = data_LOAD';
    q = data_LOAD(1:150,2);
    for i = 1:3
        fgets(fid);
    end
    %Read in the tube used
    tube_name = fgetl(fid);
    listOTubes = get(handles.popupmenu2, 'String');
    index = find(strncmp(tube_name, listOTubes, length(tube_name)));
    set(handles.popupmenu2, 'Value', index(1));
    %Read in the model name
    for i = 1:3
        model_name = fgetl(fid);
    end
    if strcmp(model_name, 'TASMICS')
        set(handles.radiobutton1, 'Value', 1);
        set(handles.radiobutton2, 'Value', 0);
    elseif strcmp(model_name, 'TASMIP')
        set(handles.radiobutton2, 'Value', 1);
        set(handles.radiobutton1, 'Value', 0);
    else
        msgbox('The file you saved did not have the specify the model correctly');
    end
    
    %Read in kVp
    for i = 1:3
        kVp = fgetl(fid);
    end 
    set(handles.edit18, 'String', kVp);
    
    %Read in kV Ripple
    for i = 1:3
        kVripple = fgetl(fid);
    end
    set(handles.edit2, 'String', kVripple);
    
    %Read in mmCu
    for i = 1:3
        mmCu = fgetl(fid);
    end
    set(handles.edit26, 'String', mmCu);
    CuThick = str2double(mmCu);
    
    %Read in mmAl
    for i = 1:3
        mmAl = fgetl(fid);
    end
    set(handles.edit3, 'String', mmAl);
    AlThick = str2double(mmAl);
    
    %Read both compound and elemental filters
    for i = 1:2
        fgetl(fid);
    end
    fileAsCell = textscan(fid, '(%c=%d)__%fmm', 'Delimiter','\n');
    fclose(fid);
    elemFilterCounter = 1;
    compFilterCounter = 1;
    for i = 1:size(fileAsCell{1}, 1)
        character = fileAsCell{1}(i,1);
        if strcmp(character, 'Z')
            filter_list(elemFilterCounter,1) = fileAsCell{2}(i,1);
            filter_list(elemFilterCounter,2) = fileAsCell{3}(i, 1);            
            elemFilterCounter = elemFilterCounter +1;
        elseif fileAsCell{1}(i, 1) == 'C'
            filter_list_comp(compFilterCounter,1) = fileAsCell{2}(i,1);
            filter_list_comp(compFilterCounter,2) = fileAsCell{3}(i,1);
            compFilterCounter = compFilterCounter + 1;
        else
            msgbox('Could not differentiate between compound and element filter');
        end
    end
    list2='';
    for j=1:size(filter_list,1),
    temp = strcat('(Z=',num2str(filter_list(j,1)),')__',num2str(filter_list(j,2)),'mm');
        if j==1
            list2 = temp;
        else
            list2 = strvcat(list2,temp);
        end    
    end
    list1 = '';
    for i=1:size(filter_list_comp,1)
        temp = strcat('(C=',num2str(filter_list_comp(i,1)),')__',num2str(filter_list_comp(i,2)),'mm');
        list1 = strvcat(list1,temp);
    end
    set(handles.listbox3, 'String', strvcat(list1, list2));
    
    string_list = get(handles.popupmenu2, 'String');
    val = get(handles.popupmenu2, 'Value');
    tube_selected = string_list{val};
    
    tubeFilters = tubeSettings(tube_selected);
       
    filters = spektrInherentFiltrationDisplay(tubeFilters);
    
    hObject = findobj('Tag', 'listbox8');
    set(hObject, 'String', filters(:, 1), 'Value', 1);
    
    hObject = findobj('Tag', 'listbox9');
    set(hObject, 'String', filters(:, 2), 'Value', 1);

    
    messageBox = msgbox('LOADING FILE REQUIREMENTS:                                                                                                        The file which is loaded must be a tab delimited ASCII text file.                  FILE FORMAT: 150x2 table of the following form:                                       [ monoenergies photon_output ; .. .. ; .. .. ]','SPEKTR 1.1');

end
% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

cla;

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

FPE = round(spektrFluencePerExposure(q));
set(handles.edit10,'String',num2str(FPE));

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Equivalent mm Al

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

% change program state to busy
set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

% v2: generate unfiltered spectrum at specified kVp, and pass as input
% to equivalent filtration functions (previously only for 100 kVp)

% Extract kVp
kVp = str2double(get(handles.edit18,'string'));

% Extract kVRipple
kVRipple = str2double(get(handles.edit2,'string'));

% Extract mm Al
AlFilterThick = str2double(get(handles.edit3,'string'));

% Generate x-ray spectrum
qUnfiltered = spektrSpectrum(kVp,[AlFilterThick kVRipple]);

value = 0;
value2 = 0;
value3 = 0;

% find the equiv mm Al of elements
if size(filter_list,1)==0
    ;
else
    value = spektrEquiv_mmAl(qUnfiltered,filter_list);
end

% find the equiv mm Al of compounds
if size(filter_list_comp,1)==0
    ;
else
    % v2: correct bug in v0&v1 by using a new function for NIST compounds
    value2 = spektrEquiv_mmAl_CompoundsNIST(qUnfiltered,filter_list_comp);
end

% find the equiv mm Al of generated compounds
if generate_compound_exists==1
    value3 = spektrEquiv_mmAl_Compound(qUnfiltered,mu_compound,comp_thickness);
else
    ;
end

% sum all mm Al contributions
value = value+value2+value3;

% set the mm Al field value
set(handles.edit11,'String',num2str(value));

% change program state to ready
set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%
%  * Load *  %
%%%%%%%%%%%%%%

[filename, pathname] = uigetfile('*.*', 'LOAD X-RAY SPECTRA FROM FILE');

%%% Set INFO in EditText objects in LOAD frame
set(handles.edit9,'String',strcat(pathname,filename));


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%%%%%%%%%%%%%
%  * Save *  %
%%%%%%%%%%%%%%

[filename, pathname] = uigetfile('*.*', 'SAVE X-RAY SPECTRA TO FILE');

%%% Set INFO in EditText objects in LOAD frame
set(handles.edit8,'String',strcat(pathname,filename));


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a
%        double


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in listbox4.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to listbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox4


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Add compound filter to filter list

global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

%filter materials from listbox
hObject = findobj('Tag','listbox4');
val = get(hObject,'Value');
string_list = get(hObject,'String');
filter_to_add = strtok((string_list{val})); % convert from cell array to string

%filter materials from listbox
thickness = str2double(get(handles.edit15,'string'));

% Add filter materials to filter_list_comp
if size(filter_list_comp,1)==0
    filter_list_comp(1,1) = spektrCompound2C(filter_to_add);
    filter_list_comp(1,2) = thickness;
    row = 1;
else
    row = size(filter_list_comp,1);
    row = row+1;
    filter_list_comp(row,1) = spektrCompound2C(filter_to_add);
    filter_list_comp(row,2) = thickness;
end

list = [];

% Generate Filter List [Z thickness;.. ..;.. ..];

if size(filter_list,1)==0
    condition = 1;
else
    % For elemental filters
    for j=1:size(filter_list,1),
        temp = strcat('(Z=',num2str(filter_list(j,1)),')__',num2str(filter_list(j,2)),'mm');
        if j==1
            list = temp;
        else
            list = strvcat(list,temp);
        end    
    end
    condition= 0;
end

% For compound filters
for j=1:size(filter_list_comp,1),
    temp = strcat('(C=',num2str(filter_list_comp(j,1)),')__',num2str(filter_list_comp(j,2)),'mm');
    if condition==1 & j==1
        list = temp;
    else
        list = strvcat(list,temp);
    end    
end

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if generate_compound_exists==1;
    if comp_thickness==0
        ;
    else
        temp = strcat('New.Comp','_',num2str(comp_thickness),'mm');
        list = strvcat(list,temp);
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ADDED
%list = strvcat(list,' ');    
set(handles.listbox3,'String',list);

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Remove filter from list

global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

%filter materials from listbox
hObject = findobj('Tag','listbox3');
val3 = get(hObject,'Value');

% find the length of the element list
filter_list_length = size(filter_list,1);

% find the length of the compound list
filter_list_comp_length = size(filter_list_comp,1);

% find the index of the compound in the compound list
difference = filter_list_length-val3;

% delete the compound of interest

if difference<0 & ~isempty(filter_list_comp)
    row_to_delete = abs(difference);
    % Delete the filter of interest
    filter_list_comp(row_to_delete,:) = [];
else
    ;
end

% Generate the listing of filters/thicknesses in the listbox3
list = [];

if size(filter_list,1)==0
    condition = 1;
else
    % Generate elemental filter list
    for j=1:size(filter_list,1),
        temp = strcat('(Z=',num2str(filter_list(j,1)),')__',num2str(filter_list(j,2)),'mm');
        if j==1
            list = temp;
        else
            list = strvcat(list,temp);
        end    
    end
    condition = 0;
end

% Generate compound filter list

for i=1:size(filter_list_comp,1),
    temp = strcat('(C=',num2str(filter_list_comp(i,1)),')__',num2str(filter_list_comp(i,2)),'mm');
    if condition==1 & i==1
        list = temp;
    else
        list = strvcat(list,temp);
    end    
end

% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if generate_compound_exists==1;
    if comp_thickness==0
        ;
    else
        temp = strcat('New.Comp','_',num2str(comp_thickness),'mm');
        list = strvcat(list,temp);
    end
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ADDED
%list = strvcat(list,' ');    
set(handles.listbox3,'String',list);
selection = get(handles.listbox3,'Value');
if selection > size(list,1) & size(list,1)>0
    set(handles.listbox3,'Value',size(list,1))
end
set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

meanEnergy = spektrMeanEnergy(q);
set(handles.edit16,'String',num2str(meanEnergy));

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global filter_list
global filter_list_comp
global element_list
global mu_compound

close(spektr);
spektrCompound;

% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filter_list;
global filter_list_comp;
global mu_compound;
global q;
global q0;
global element_list;
global comp_string
global comp_thickness
global generate_compound_exists
global AlThick
global CuThick

set(handles.edit18, 'String', '120');
set(handles.edit2, 'String', '0');
set(handles.edit26, 'String', '0');
set(handles.edit3, 'String', '2.5');
set(handles.edit4, 'String', '0');
set(handles.edit5, 'String', '0');
set(handles.edit10, 'String', '0');
set(handles.edit16, 'String', '0');
set(handles.radiobutton2, 'value', 0);
set(handles.radiobutton1, 'value', 1);
set(handles.popupmenu1, 'value', 1);
set(handles.checkbox1, 'value', 1);
set(handles.edit11, 'String', '0');
set(handles.edit7, 'String', '0');
set(handles.edit15, 'String', '0');
set(handles.listbox3, 'String', {});
set(handles.edit17, 'String', '');
set(handles.edit28, 'String', '0');
set(handles.edit29, 'String', '0');

%Reset lisbox 8 and 9 that contain the inherent filtrations
AlThick = str2double(get(handles.edit3, 'String'));
CuThick = str2double(get(handles.edit4, 'String'));

inhBooneFewell = tubeSettings('Boone/Fewell');

AlFilt = [13 AlThick];
CuFilt = [29 CuThick];
row1 = inhBooneFewell(1,:);
row2 = inhBooneFewell(2,:);

totalInh = zeros(4,2);
totalInh(1,:) = row1;
totalInh(2,:) = row2;

filters = spektrInherentFiltrationDisplay(totalInh);

set(handles.listbox8, 'String', filters(:,1)); 
set(handles.listbox9, 'String', filters(:,2));

filter_list = [];
filter_list_comp = [];
q = [];
q0 = [];
cla;
element_list =[];
comp_string = '';
generate_compound_exists = 0;

set(handles.popupmenu2, 'Value', 1);

% --- Executes on button press in pushbutton23.
function pushbutton23_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CLEAR LIST

% Remove filter from list

global q
global q0 % initial x-ray energy spectrum before added filtration
global filter_list
global filter_list_comp
global element_list
global mu_compound
global comp_string
global comp_thickness

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

% Delete the ENTIRE filter list of interest
filter_list_comp = [];
filter_list = [] ;
element_list = [];
comp_thickness = 0;
comp_string = '';

% Generate the listing of filters/thicknesses in the listbox3
list = [];

% Reset Initial Spectrum
q = q0;

% ADDED
set(handles.listbox3,'String',list);
set(handles.listbox3,'Value',1);

% Clear generated compound window name
set(handles.edit17,'String',list);

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes on button press in pushbutton24.
function pushbutton24_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global q
global element_list
global mu_compound
global comp_string
global comp_thickness
global generate_compound_exists

generate_compound_exists = 1;

set(handles.edit14,'String','BUSY','ForegroundColor','red');
drawnow;

if comp_thickness == 0
    set(handles.edit17,'String','');
else
    temp = strcat('New.Comp_',num2str(comp_thickness),'mm');
    set(handles.edit17,'String',comp_string);
    set(handles.listbox3,'String',temp);
end

set(handles.edit14,'String','READY','ForegroundColor',[0 0.5 0]);

% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% global q
% global filter_list
% global filter_list_comp
% global element_list
% global mu_compound
% 
% set(handles.edit14,'String','BUSY');
% set(handles.edit14,'ForegroundColor','red');
% drawnow;
% 
% EnergyVector=[1:1:150]';
% data_SAVE=[EnergyVector q];
% 
% % write data to file
% file_SAVE='workspace_q';
% fid=fopen(file_SAVE,'w');
% for i=1:150,
%     fprintf(fid,'%d   %d\r',data_SAVE(i,1),data_SAVE(i,2));
% end
% fclose(fid);
% 
% load('workspace_q');
% 
% set(handles.edit14,'String','READY');
% set(handles.edit14,'ForegroundColor',[0 0.5 0]);


function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function mutual_exclude(off)
% This will set the value of the items in 'off' to 0
set(off, 'Value', 0)

% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2
%Turn radio button 1 off when radiobutton2 is selected
if get(hObject, 'Value') == 1
    off = [handles.radiobutton1];
    mutual_exclude(off);
else
    set(hObject, 'Value', 1);
end


% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
% Turn radio button 2 off when radio button 1 is selected
if get(hObject, 'Value') == 1
    off = [handles.radiobutton2];
    mutual_exclude(off)
else 
    set(hObject, 'Value', 1);
end

% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%Leave radio button 1 on as a default
set(hObject,'value',1)

function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox8.
function listbox8_Callback(hObject, eventdata, handles)
% hObject    handle to listbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox8


% --- Executes during object creation, after setting all properties.
function listbox8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
global AlThick;
global CuThick;

inhBooneFewell = tubeSettings('Boone/Fewell');

AlThick = 2.5;
CuThick = 0;

AlFilt = [13 AlThick];
CuFilt = [29 CuThick];
row1 = inhBooneFewell(1,:);
row2 = inhBooneFewell(2,:);

totalInh = zeros(4,2);
totalInh(1,:) = row1;
totalInh(2,:) = row2;
totalInh(3,:) = AlFilt;
totalInh(4,:) = CuFilt;

filters = spektrInherentFiltrationDisplay(totalInh);

set(hObject, 'String', filters(:,1)); 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox9.
function listbox9_Callback(hObject, eventdata, handles)
% hObject    handle to listbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox9 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox9


% --- Executes during object creation, after setting all properties.
function listbox9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
%Array is meant to contain thickness of Al and Cu from X-ray tube Settings
%Panel but that field is unreachable from here
global AlThick
global CuThick

AlThick = 2.5;
CuThick = 0;

inhBooneFewell = tubeSettings('Boone/Fewell');

AlFilt = [13 AlThick];
CuFilt = [29 CuThick];
row1 = inhBooneFewell(1,:);
row2 = inhBooneFewell(2,:);

totalInh = zeros(4,2);
totalInh(1,:) = row1;
totalInh(2,:) = row2;


filters = spektrInherentFiltrationDisplay(totalInh);

set(hObject, 'String', filters(:,2)); 

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double
global CuThick
global AlThick

CuThick = str2double(get(hObject, 'String'));


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

global CuThick
set(hObject, 'String', '0');

CuThick = str2double(get(hObject, 'String'));

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function axes9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes9

htext = text('Parent',hObject, ...
    'String','ADDED FILTRATION:', ...
    'Rotation',90, 'Position', [.5,.5], 'FontName', 'TIMES', 'FontSize', 14, 'FontWeight', 'Bold', 'FontUnits', 'points');

set(htext, 'horizontalalignment', 'center');
set(htext, 'verticalalignment', 'middle');

set(hObject, 'Color', [0.561, 0.561, 0.561]);
set(hObject,'Visible','on');



% --- Executes on button press in pushbutton28.
function pushbutton28_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global q;
airKermaStr = sprintf('%.4E', spektrAirKerma(q));
set(handles.edit28, 'String', airKermaStr);

% --- Executes during object creation, after setting all properties.
function pushbutton28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', '0');

% --- Executes on button press in pushbutton29.
function pushbutton29_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global q;

set(handles.edit29,'String', num2str(uint32(spektrFluencePerAirKerma(q))));


function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', '0');
