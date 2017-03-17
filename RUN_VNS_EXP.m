function varargout = RUN_VNS_EXP(varargin)
% RUN VNS experiment 
% Last Modified by GUIDE v2.5 07-Mar-2017 10:38:13
% YBS/MFY March 2017


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @RUN_VNS_EXP_OpeningFcn, ...
    'gui_OutputFcn',  @RUN_VNS_EXP_OutputFcn, ...
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


% --- Executes just before RUN_VNS_EXP is made visible.
function RUN_VNS_EXP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RUN_VNS_EXP (see VARARGIN)

% Choose default command line output for RUN_VNS_EXP
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%% define DAQ settings section
% Define analog and digital sessions
% release the DAQ card if busy from another session
try
    daqreset; 
catch
end

% Check if daq devices are available and abort if they are not
d = daq.getDevices;
if isempty(d)
    warndlg('No DAQ object found. Aborting','RUN VNS experiment');
    return
end
    
% Establish analog and digital connections
try
    continS = daq.createSession('ni');
    analog_ch_1 = continS.addAnalogOutputChannel('Dev1','ao0', 'Voltage'); % Sound (speaker)
    analog_ch_2 = continS.addAnalogOutputChannel('Dev1','ao1', 'Voltage'); % SNT (stimulator)
    analog_ch_3 = continS.addAnalogOutputChannel('Dev1','ao2', 'Voltage'); % Wash (valve)
    continS.Rate = 10000; % sampling rate of data
    
    digiS = daq.createSession ('ni');
    % 8 bits for re[prting trial ID
    digi_ch_0 = digiS.addDigitalChannel('Dev1', 'Port0/Line0', 'OutputOnly');
    digi_ch_1 = digiS.addDigitalChannel('Dev1', 'Port0/Line1', 'OutputOnly');
    digi_ch_2 = digiS.addDigitalChannel('Dev1', 'Port0/Line2', 'OutputOnly');
    digi_ch_3 = digiS.addDigitalChannel('Dev1', 'Port0/Line3', 'OutputOnly');
    digi_ch_4 = digiS.addDigitalChannel('Dev1', 'Port0/Line4', 'OutputOnly');
    digi_ch_5 = digiS.addDigitalChannel('Dev1', 'Port0/Line5', 'OutputOnly');
    digi_ch_6 = digiS.addDigitalChannel('Dev1', 'Port0/Line6', 'OutputOnly');
    digi_ch_7 = digiS.addDigitalChannel('Dev1', 'Port0/Line7', 'OutputOnly');
catch
    warndlg('Unable to establish DAQ session. Aborting','RUN VNS experiment');
    return
end

% save sessions definitions into DATA structure
handles.DATA.analog_session  = continS;
handles.DATA.digital_session = digiS;
handles.DATA.pause   = 0;
handles.DATA.stopped = 0;


%% establish paths and create forlder if these do not exist
% get or create the log file - one is used per day
[BASE_P,~,~] = fileparts(mfilename('fullpath'));

LOG_FILE_PATH     = [BASE_P filesep 'log_files'];
PARAM_FILE_PATH   = [BASE_P filesep 'exp_params_files'];

if ~exist(LOG_FILE_PATH,'dir')
    mkdir(LOG_FILE_PATH);
end
if ~exist(PARAM_FILE_PATH,'dir')
    mkdir(PARAM_FILE_PATH);
end
handles.DATA.PARAM_FILE_PATH = PARAM_FILE_PATH;


%% Check if a log file exists, and if so, update the interface
log_file_name = [ LOG_FILE_PATH '\VNS_EXP_LOG_' date];
handles.DATA.log_file_name = log_file_name;
if exist([log_file_name '.mat'],'file')
    load(log_file_name,'log_data');
    
    if isfield(log_data,'params')
        k = 1;    
        for i = 1:length(log_data)
            if log_data(i).good_trial 
                SS{k} = [log_data(i).stim_name '(' num2str(log_data(i).unique_trial_id) ')'];
                k =  k + 1;
            end
        end
        if k > 1
            set(handles.event_listbox,'string',SS);
        end
             
    end
    if isempty(log_data)
        handles.DATA.unique_trial_id = 0;
    else
        handles.DATA.unique_trial_id = log_data(end).unique_trial_id;
    end
else
    log_data = [];    
    save(log_file_name,'log_data');
    handles.DATA.unique_trial_id = 0;
end


handles.DATA.log_file_name = log_file_name;
handles.DATA.log_data      = log_data;

guidata(hObject,handles);
% load the default settings defined prviously
load_default_params_button_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Outputs from this function are returned to the command line.
function varargout = RUN_VNS_EXP_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function VNO_stim_frequency_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function VNO_stim_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_stim_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function VNO_stim_duration_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function VNO_stim_duration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_stim_duration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VNO_stim_pulse_width_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function VNO_stim_pulse_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_stim_pulse_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VNO_stim_interphase_delay_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function VNO_stim_interphase_delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_stim_interphase_delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function VNO_stim_amplitude_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function VNO_stim_amplitude_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_stim_amplitude_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ITI_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ITI_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ITI_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function application_to_stim_delay_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function application_to_stim_delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to application_to_stim_delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stim_to_wash_delay_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function stim_to_wash_delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stim_to_wash_delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wash_start_to_wash_stim_delay_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function wash_start_to_wash_stim_delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wash_start_to_wash_stim_delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function wash_stim_to_wash_end_delay_edit_Callback(hObject, eventdata, handles)
update_stim_params(hObject,handles);


% --- Executes during object creation, after setting all properties.
function wash_stim_to_wash_end_delay_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wash_stim_to_wash_end_delay_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function update_stim_params(hObject,handles)


% get values for all
Params.SR = handles.DATA.analog_session.Rate; % SR in Hz

StimParams(1).name = 'ITI_edit';
StimParams(1).default = 5;
StimParams(1).range = [1 60];
StimParams(2).name = 'application_to_stim_delay_edit';
StimParams(2).default = 10;
StimParams(2).range = [2 30];
StimParams(3).name = 'stim_to_wash_delay_edit';
StimParams(3).default = 20;
StimParams(3).range = [2 40];
StimParams(4).name = 'wash_start_to_wash_stim_delay_edit';
StimParams(4).default = 10;
StimParams(4).range = [1 20];
StimParams(5).name = 'wash_stim_to_wash_end_delay_edit';
StimParams(5).default = 10;
StimParams(5).range = [2 30];
StimParams(6).name = 'VNO_stim_frequency_edit';
StimParams(6).default = 10;
StimParams(6).range = [5  40];
StimParams(7).name = 'VNO_stim_duration_edit';
StimParams(7).default = 1.6;
StimParams(7).range = [0.1  2];
StimParams(8).name = 'VNO_stim_pulse_width_edit';
StimParams(8).default = 2;
StimParams(8).range = [1  3];
StimParams(9).name = 'VNO_stim_interphase_delay_edit';
StimParams(9).default = 0.2;
StimParams(9).range = [0.1 0.3];
StimParams(10).name = 'VNO_stim_amplitude_edit';
StimParams(10).default = 10;
StimParams(10).range = [0 10];

for i = 1:length(StimParams)
    eval(['tmpval  = str2num(get(handles.' StimParams(i).name ',''string''));' ]);
    if isempty(tmpval)
        errordlg([StimParams(i).name([1:end-5]) ' must be a number']);
        tmpval = StimParams(i).default;
    end
    if tmpval < StimParams(i).range(1) ||  tmpval > StimParams(i).range(2)
        errordlg([StimParams(i).name([1:end-5]) ' must be between ' num2str(StimParams(i).range(1)) ' and ' num2str(StimParams(i).range(2))]);
        tmpval = StimParams(i).default;
    end
    eval(['Params.' StimParams(i).name([1:end-5]) ' = ' num2str(tmpval) ';']);
    eval(['set(handles.' StimParams(i).name ',''string'',''' num2str(tmpval) ''')']);
end



[SOUND_chan,VNO_chan,VALVE_chan, apply_sample] = generate_single_VNS_trial_scan(Params);
apply_time = apply_sample/Params.SR;

timevec = [1:length(SOUND_chan)]/Params.SR;
ITI = Params.ITI;
TE = timevec(end);
TD = TE + ITI;

% plot the signals in the relevant axes of the GUI
axes(handles.soundaxes);
hold off
plot(timevec,SOUND_chan,'g')
set(gca,'ylim',[-12 12],'xlim',[-ITI TE],'ytick',[],'xtick',[]);
hold on; lh(1) = line([apply_time apply_time],[-12 12]); 
zeroLH(1) = line([0 0],[-12 12]);
ch(1) = line([-ITI -ITI],[-12 12]);
ylabel('sound (V)');

axes(handles.stimaxes);
hold off
plot(timevec,VNO_chan,'r')
set(gca,'ylim',[-12 12],'xlim',[-ITI TE],'ytick',[],'xtick',[]);
hold on; lh(2) = line([apply_time apply_time],[-12 12]); 
zeroLH(2) = line([0 0],[-12 12]);
ch(2) = line([-ITI -ITI],[-12 12]);
ylabel('SNT (V)');

axes(handles.valveaxes);
hold off
plot(timevec,VALVE_chan,'b')
set(gca,'ylim',[-1 5],'xlim',[-ITI TE],'ytick',[]);
set(gca,'xtick',[-ITI 0:5:TE]);
hold on; lh(3) = line([apply_time apply_time],[-1 5]); 
zeroLH(3) = line([0 0],[-5 5]);
ch(3) = line([-ITI -ITI],[-1 5]);
ylabel('Valve (V)');
xlabel('Time(S)')
set(lh,'color','k','linestyle',':', 'linewidth',2);

% the moving cursor
set(ch,'color','r','linewidth',2);
set(zeroLH,'color','k','linewidth',1);

ITI_zeros = zeros(1,ceil(Params.SR*ITI));

handles = guidata(hObject);
DATA = handles.DATA;
DATA.Params = Params;
UPV = -10; % minimum amplitude of out voltage for the sound signal
DATA.SOUND_chan  = [ones(1,100)*UPV ITI_zeros(1:(end-100)) SOUND_chan(1:end-5) zeros(1,5)];% add 100 high sound samples in the begining of each trial
DATA.VNO_chan    = [ITI_zeros VNO_chan];
DATA.VALVE_chan  = [ITI_zeros VALVE_chan];
DATA.plot_line_handles = ch;
DATA.trial_duration = TD;
DATA.apply_time = apply_time;
DATA.SR = Params.SR;
handles.DATA = DATA;
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



% --- Executes on button press in run_once_button.
function run_once_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_once_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(gcbo);

DATA = handles.DATA;
ITI = DATA.Params.ITI;
TD = DATA.trial_duration;

continS = DATA.analog_session;
continS.queueOutputData([DATA.SOUND_chan; DATA.VNO_chan ; DATA.VALVE_chan]');
continS.startBackground();

tic
TP = 0.2; % Temporal resolution of cursor.
cursor_timer = timer('TimerFcn',{@plot_cursor_callback,handles,ITI}, 'Period', TP,'ExecutionMode','fixedRate','TasksToExecute',floor((TD+TP)/TP),'name','cursor_timer');
DATA.cursor_timer = cursor_timer;
handles.DATA = DATA;

guidata(hObject,handles);
start(cursor_timer);





% --- Executes on button press in stop_button.
function stop_button_Callback(hObject, eventdata, handles)
handles = guidata(gcbo);

DATA = handles.DATA;

continS = DATA.analog_session;
digiS   = DATA.digital_session;
ITI = DATA.Params.ITI;

% continS.startForeground();
if continS.IsRunning
    try
        continS.stop();
    catch
        return
    end
else
    return
end

cursor_timer = DATA.cursor_timer;
stop(cursor_timer);
delete(cursor_timer);% why not ...

LHs = DATA.plot_line_handles;
for i = 1:length(LHs)
    set(LHs(i),'XData',[-ITI -ITI]);
end
handles.DATA.stopped = 1;

% reset the digital display
digiS.outputSingleScan([0 0 0 0 0 0 0 0]); % reset bit mask
for i = 1:8
    eval(['set(handles.bit_panel_' num2str(i) ',''BackgroundColor'',[0.212 0.208 0.200])']);
end

guidata(hObject,handles);


% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[BASE_P,~,~] = fileparts(mfilename('fullpath'));
STIM_FILE_PATH     = [BASE_P filesep 'stimulus_files'];
if ~exist(STIM_FILE_PATH,'dir')
    mkdir(STIM_FILE_PATH);
end

% Load the file
[filename, filepath, ~] = uigetfile([STIM_FILE_PATH filesep '*.txt'], 'Select an stimulus file');
if ~filename
    return
end

% Read stimuli from file
stimulus_strings = read_stimulus_file([filepath filesep filename]);
% set(handles.stim_file_text,'string',filename);
set(handles.all_stims_listbox,'string',[]);
% Write the entire list of odorants in the all_stims_listbox
for k = 1:length(stimulus_strings)    
    stimulus_strings{k} = [stimulus_strings{k}];
end
set(handles.all_stims_listbox,'string',stimulus_strings);


set(handles.current_stim_number_text,'string','');
set(handles.all_stims_listbox,'value',1);
set(handles.all_stims_listbox,'enable','on');

%update_event_fromfile(handles);
set(handles.run_exp_button,'enable','on');

[UL,IA,IC] = unique(stimulus_strings);
% FInd which stimulus are ES stimuli
% Generate the unique list and generate a list with a unique code for each
DATA = handles.DATA;
STIMS.list = stimulus_strings;
STIMS.unique_stimuli = UL;
STIMS.unique_stimulus_codes = IC;
DATA.next_stim = 1;
DATA.STIMS  = STIMS;

handles.DATA = DATA;


set(handles.current_stim_number_text,'string','');
set(handles.current_stim_text,'string','');
set(handles.next_stim_text,'string',STIMS.list(1));

update_stim_params(hObject,handles);

guidata(hObject,handles);




%

% --- Executes on selection change in all_stims_listbox.
function all_stims_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to all_stims_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

warndlg('Note that by selecting a different stimulus from the list changes trial flow', 'RUN VNS EXP');






% Hints: contents = cellstr(get(hObject,'String')) returns all_stims_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from all_stims_listbox


% --- Executes during object creation, after setting all properties.
function all_stims_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to all_stims_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns event_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from event_listbox


% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in run_exp_button.
function run_exp_button_Callback(hObject, eventdata, handles)
% hObject    handle to run_exp_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.event_listbox,'BackgroundColor',[1,1,1])
set(handles.all_stims_listbox,'BackgroundColor',[1,1,1])

stimulus_strings = handles.DATA.STIMS.list;
UL = handles.DATA.STIMS.unique_stimuli;
IC = handles.DATA.STIMS.unique_stimulus_codes;
n_stims = length(stimulus_strings);
current_stim_no = get(handles.all_stims_listbox,'value');

digiS = handles.DATA.digital_session;
continS = handles.DATA.analog_session;
% update the stimuli done box and save the data as well
% update the current stim value in the list, in the figure data and update the next stimuli etc ...



DONE = 0;

while ~DONE
    
    % disable buttons during execution
    getset_param_vals(hObject, eventdata, handles,'disable');
    set(handles.VNO_single_stimulation,'Enable','off');
    set(handles.open_valve_button,'Enable','off');
    set(handles.all_stims_listbox,'Enable','off');
    set(handles.show_SNT_train_button,'Enable','off');
    
    
    handles.DATA.unique_trial_id = handles.DATA.unique_trial_id + 1;
    guidata(hObject,handles);
    
    % Get next stim number
    % no, the next stim is always the current one in the list.
    
    % take the current stimulus from the list
    % write it in the now presenting box
    set(handles.current_stim_text,'string',stimulus_strings{current_stim_no});
    set(handles.current_stim_number_text,'string',num2str(num2str(handles.DATA.unique_trial_id)));
    
    % and if this is not the last item, write the next stim in the up next box
    if current_stim_no < n_stims
        set(handles.next_stim_text,'string',stimulus_strings{current_stim_no+1});
    else
        set(handles.next_stim_text,'string','');
    end
        
        
    update_stim_params(hObject,handles);
    
    % Get the appropriate bit mask and set it on the digital port
    bit_mask = fliplr(uint8(dec2bin(handles.DATA.unique_trial_id,8)) - uint8(dec2bin(0,8)));    
    
    digiS.outputSingleScan(double(bit_mask));
    
    
    % Update the bit display
    for i = 1:8
        if bit_mask(i)
            eval(['set(handles.bit_panel_' num2str(i) ',''BackgroundColor'',''r'')']);
        else
            eval(['set(handles.bit_panel_' num2str(i) ',''BackgroundColor'',[0.212 0.208 0.200])']);
        end
    end
    % Run the trial
    run_once_button_Callback(hObject, eventdata, handles);
    
    
    RUNNING = 1;
    while  RUNNING
        RUNNING = continS.IsRunning ;
        pause(0.5);
    end
    % if it was completed successfuly - we advance to the next trial - moving the
    % stimulus list value
    % otherwise we break...
    handles = guidata(gcbo);
    
    if handles.DATA.stopped
        % We do not want to advance to the next stimulus
        % We do not need to update the list so there is nothing to do
        % really
        DONE = 1;
        handles.DATA.stopped = 0;
        guidata(hObject,handles);
        good_trial = 0;
    elseif current_stim_no < n_stims
        % if no pause and we are not at the end of the list
        % we do not need to update because we will enter the loop
        % again
        % update the completed stimuli list box
        SS = get(handles.event_listbox,'string');
        SS{length(SS)+1} = [stimulus_strings{current_stim_no} '(' num2str(handles.DATA.unique_trial_id) ')'];
        set(handles.event_listbox,'string',SS);
                               
        good_trial = 1;
        
        % and prepare it for the next one
        current_stim_no = current_stim_no + 1;
        set(handles.all_stims_listbox,'value',current_stim_no);
        %check the length of the intan file
        format_date=('ddmmmyy');
        date_for_folder=lower(datestr(now,format_date));
        
        
        % we do everything except continue
        if handles.DATA.pause
            handles.DATA.pause = 0;
            guidata(hObject,handles);
            DONE = 1;
        end                
        
    else % we reached the end of the list
        % we have to reset because we won't enter this loop again
        
        % update the completed stimuli list box
        SS = get(handles.event_listbox,'string');
        SS{length(SS)+1} = [stimulus_strings{current_stim_no} '(' num2str(handles.DATA.unique_trial_id) ')'];
        set(handles.event_listbox,'string',SS);
        
        good_trial = 1;        
        
        DONE = 1;
        current_stim_no = 1;
        set(handles.all_stims_listbox,'value',current_stim_no);
        set(handles.current_stim_text,'string',stimulus_strings{current_stim_no});
        set(handles.current_stim_number_text,'string',num2str(handles.DATA.unique_trial_id));
        set(handles.next_stim_text,'string',stimulus_strings{current_stim_no+1});
        
    end
       
    
    Params = getset_param_vals(hObject, eventdata, handles); % but add this    
    np = length(Params);
    Params(np+1).value = handles.DATA.SR;
    Params(np+1).name = 'SR';
    Params(np+2).value = handles.DATA.apply_time;
    Params(np+2).name = 'apply time';   
    
    load(handles.DATA.log_file_name,'log_data');    
    nt = length(log_data);
    log_data(nt+1).good_trial = good_trial;   
    if current_stim_no==1
        log_data(nt+1).stim_name  = stimulus_strings{end};
    else
        log_data(nt+1).stim_name  = stimulus_strings{current_stim_no-1};
    end
    log_data(nt+1).unique_trial_id  = (handles.DATA.unique_trial_id);
    log_data(nt+1).now        = datestr(now);     
    log_data(nt+1).params     = Params;
    save(handles.DATA.log_file_name,'log_data'); 
    guidata(hObject,handles);
    
end

getset_param_vals(hObject, eventdata, handles,'enable');
set(handles.VNO_single_stimulation,'Enable','on');
set(handles.open_valve_button,'Enable','on');
set(handles.all_stims_listbox,'Enable','on');
set(handles.show_SNT_train_button,'Enable','on');

    


digiS.outputSingleScan(0*bit_mask); % reset bit mask
update_stim_params(hObject,handles);
for i = 1:8
    eval(['set(handles.bit_panel_' num2str(i) ',''BackgroundColor'',[0.212 0.208 0.200])']);
end




function plot_cursor_callback(obj,event,handles,ITI)


thistock = toc;
handles = guidata(handles.figure1);
DATA = handles.DATA;
LHs = DATA.plot_line_handles;
for i = 1:length(LHs)
    set(LHs(i),'XData',[thistock thistock] - ITI);
end



% --- Executes on button press in pause_experiment_button.
function pause_experiment_button_Callback(hObject, eventdata, handles)

handles = guidata(gcbo);
handles.DATA.pause = 1;
guidata(hObject,handles);



% --- Executes on button press in save_params_as_default_button.
function save_params_as_default_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_params_as_default_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% String parameters
StimParams(1).name = 'ITI_edit';
StimParams(2).name = 'application_to_stim_delay_edit';
StimParams(3).name = 'stim_to_wash_delay_edit';
StimParams(4).name = 'wash_start_to_wash_stim_delay_edit';
StimParams(5).name = 'wash_stim_to_wash_end_delay_edit';
StimParams(6).name = 'VNO_stim_frequency_edit';
StimParams(7).name = 'VNO_stim_duration_edit';
StimParams(8).name = 'VNO_stim_pulse_width_edit';
StimParams(9).name = 'VNO_stim_interphase_delay_edit';
StimParams(10).name = 'VNO_stim_amplitude_edit';


for i = 1:length(StimParams)
    eval(['Param_str{i}  = get(handles.' StimParams(i).name ',''string'');' ]);        
end

PARAM_FILE_PATH = handles.DATA.PARAM_FILE_PATH;
save([PARAM_FILE_PATH '\default_params'],'StimParams','Param_str');




% --- Executes on button press in load_default_params_button.
function load_default_params_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_default_params_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PARAM_FILE_PATH = handles.DATA.PARAM_FILE_PATH;
fname = [PARAM_FILE_PATH '\default_params.mat'];
if exist(fname,'file')
    load(fname);
else
    warndlg('A user defined default param file was not found','RUN VNS EXP');
    return
end

% String parameters
StimParams(1).name = 'ITI_edit';
StimParams(2).name = 'application_to_stim_delay_edit';
StimParams(3).name = 'stim_to_wash_delay_edit';
StimParams(4).name = 'wash_start_to_wash_stim_delay_edit';
StimParams(5).name = 'wash_stim_to_wash_end_delay_edit';
StimParams(6).name = 'VNO_stim_frequency_edit';
StimParams(7).name = 'VNO_stim_duration_edit';
StimParams(8).name = 'VNO_stim_pulse_width_edit';
StimParams(9).name = 'VNO_stim_interphase_delay_edit';
StimParams(10).name = 'VNO_stim_amplitude_edit';

for i = 1:length(StimParams)
    eval(['set(handles.' StimParams(i).name ',''string'',''' Param_str{i} ''');']);        
end

update_stim_params(hObject,handles);




% --- Executes on button press in save_params_to_file_button.
function save_params_to_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_params_to_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% String parameters
StimParams(1).name = 'ITI_edit';
StimParams(2).name = 'application_to_stim_delay_edit';
StimParams(3).name = 'stim_to_wash_delay_edit';
StimParams(4).name = 'wash_start_to_wash_stim_delay_edit';
StimParams(5).name = 'wash_stim_to_wash_end_delay_edit';
StimParams(6).name = 'VNO_stim_frequency_edit';
StimParams(7).name = 'VNO_stim_duration_edit';
StimParams(8).name = 'VNO_stim_pulse_width_edit';
StimParams(9).name = 'VNO_stim_interphase_delay_edit';
StimParams(10).name = 'VNO_stim_amplitude_edit';

for i = 1:length(StimParams)
    eval(['Param_str{i}  = get(handles.' StimParams(i).name ',''string'');' ]);
end


PARAM_FILE_PATH = handles.DATA.PARAM_FILE_PATH;

[param_file, param_path] = uiputfile([PARAM_FILE_PATH '\*.mat'], 'save param file');
if isequal(param_file,0) || isequal(param_path,0)
    return
else
    save([param_path param_file],'StimParams','Param_str');
end


% --- Executes on button press in load_params_from_file_button.
function load_params_from_file_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_params_from_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PARAM_FILE_PATH = handles.DATA.PARAM_FILE_PATH;

[param_file, param_path] = uigetfile([PARAM_FILE_PATH '\*.mat'], 'load param file');
if isequal(param_file,0) || isequal(param_path,0)
    return
else
    load([param_path param_file],'StimParams','Param_str');
end

% String parameters
StimParams(1).name = 'ITI_edit';
StimParams(2).name = 'application_to_stim_delay_edit';
StimParams(3).name = 'stim_to_wash_delay_edit';
StimParams(4).name = 'wash_start_to_wash_stim_delay_edit';
StimParams(5).name = 'wash_stim_to_wash_end_delay_edit';
StimParams(6).name = 'VNO_stim_frequency_edit';
StimParams(7).name = 'VNO_stim_duration_edit';
StimParams(8).name = 'VNO_stim_pulse_width_edit';
StimParams(9).name = 'VNO_stim_interphase_delay_edit';
StimParams(10).name = 'VNO_stim_amplitude_edit';

for i = 1:length(StimParams)
    eval(['set(handles.' StimParams(i).name ',''string'',''' Param_str{i} ''');']);        
end


update_stim_params(hObject,handles);


function Params = getset_param_vals(hObject, eventdata, handles,operation)


% String parameters
Params(1).name = 'ITI_edit';
Params(2).name = 'application_to_stim_delay_edit';
Params(3).name = 'stim_to_wash_delay_edit';
Params(4).name = 'wash_start_to_wash_stim_delay_edit';
Params(5).name = 'wash_stim_to_wash_end_delay_edit';
Params(6).name = 'VNO_stim_frequency_edit';
Params(7).name = 'VNO_stim_duration_edit';
Params(8).name = 'VNO_stim_pulse_width_edit';
Params(9).name = 'VNO_stim_interphase_delay_edit';
Params(10).name = 'VNO_stim_amplitude_edit';

for i = 1:length(Params)
    eval(['Params(i).value  = str2num(get(handles.' Params(i).name ',''string''));' ]);    
end


more_handles{1} = 'handles.load_params_from_file_button';
more_handles{2} = 'handles.save_params_to_file_button';
more_handles{3} = 'handles.load_default_params_button';
more_handles{4} = 'handles.save_params_as_default_button';
more_handles{5} = 'handles.run_exp_button';
more_handles{6} = 'handles.load_button';


if exist('operation')
    switch operation
        case 'enable'
            for i = 1:length(Params)
                eval(['set(handles.' Params(i).name ',''enable'',''on'')']);
            end 
            for i = 1:length(more_handles)
                eval(['set(' more_handles{i} ',''enable'',''on'')']);
            end 
            
        case 'disable'
            for i = 1:length(Params)
                eval(['set(handles.' Params(i).name ',''enable'',''off'')']);
            end
            
            for i = 1:length(more_handles)
                eval(['set(' more_handles{i} ',''enable'',''off'')']);
            end 
        otherwise
            % do nothing
    end
end


% --- Executes during object creation, after setting all properties.
function block_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to block_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in VNO_single_stimulation.
function VNO_single_stimulation_Callback(hObject, eventdata, handles)
% hObject    handle to VNO_single_stimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles = guidata(hObject);
DATA=handles.DATA;
Params=DATA.Params ;
[SOUND_chan,VNO_chan,VALVE_chan] = generate_single_SNT_stim_scan(Params);
continS = DATA.analog_session;
if ~continS.IsRunning
    continS.queueOutputData([SOUND_chan; VNO_chan ; VALVE_chan ]');
    continS.startBackground();
end


% --- Executes on button press in open_valve_button.
function open_valve_button_Callback(hObject, eventdata, handles)
% hObject    handle to open_valve_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button_str=get(hObject,'String');
if strcmp(button_str,'valve (open)')
    valve_state='open';
    set(hObject,'String','valve (closed)');
elseif strcmp(button_str,'valve (closed)')
     valve_state='close';
     set(hObject,'String','valve (open)');
end
[SOUND_chan,VNO_chan,VALVE_chan] = generate_single_washvalve_scan(valve_state);
handles = guidata(hObject);
DATA=handles.DATA;
continS = DATA.analog_session;
continS.queueOutputData([SOUND_chan; VNO_chan ; VALVE_chan ]');
continS.startBackground();

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over open_valve_button.
function open_valve_button_ButtonDownFcn(hObject, eventdata, handles)
valve_handle=get(hObject);


% --- Executes during object creation, after setting all properties.
function text31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function current_stim_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_stim_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function next_stim_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_stim_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function run_exp_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to run_exp_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function stop_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function pause_experiment_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pause_experiment_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function load_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function VNO_single_stimulation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VNO_single_stimulation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function open_valve_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to open_valve_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function load_params_from_file_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_params_from_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function save_params_to_file_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_params_to_file_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function load_default_params_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to load_default_params_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function save_params_as_default_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to save_params_as_default_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function soundaxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soundaxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate soundaxes


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in show_SNT_train_button.
function show_SNT_train_button_Callback(hObject, eventdata, handles)
% hObject    handle to show_SNT_train_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = guidata(hObject);
DATA=handles.DATA;
Params=DATA.Params ;
[SOUND_chan,VNO_chan,VALVE_chan] = generate_single_SNT_stim_scan(Params);


timevec = 1000* [1:length(VNO_chan)]/Params.SR;


figure 
plot(timevec,VNO_chan,'r')
set(gca,'ylim',[-12 12]);
hold on; 
ylabel('V');
xlabel('Time (ms)');
title('single SNT pulse train')


return
