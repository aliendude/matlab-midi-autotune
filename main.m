function varargout = main(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @main_OpeningFcn, ...
                       'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for main
    handles.output = hObject;
    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;


global audio_Fs;
audio_Fs = 44100;
global recObj;
recObj = audiorecorder;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    global midi;
    global midi_y;
    global midi_Fs;

    [filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
    midi = readmidi(strcat(pathname,filename));
    [midi_y, midi_Fs] = midi2audio(midi);
    % soundsc(y, Fs);  % FM-synth
    notes = midiInfo(midi,0);%
    % compute piano-roll:
    [PR,t,nn] = piano_roll(notes);
    %display piano-roll:
    axes(handles.axes1);
    imagesc(t, nn, PR);
    axis xy;
    xlabel('time (sec)');
    ylabel('note number');

% --- Executes on button press in Grabar.
function Grabar_Callback(hObject, eventdata, handles)

    global audio_y;
    global audio_Fs;
    global recObj;
    audio_Fs = recObj.SampleRate;
    disp(get(hObject,'Value'));
    if (get(hObject,'Value') == 1)
        set(handles.label_rec,'string','Grabando');
        record(recObj);
        %play(recObj);
    else
        stop(recObj);
        set(handles.label_rec,'string','Sonido grabado.');
        audio_y = getaudiodata(recObj);
        [audio_length, a] = size(audio_y);
        disp('Audio length (s):');
        disp(audio_length/audio_Fs);
        axes(handles.axes2);
        plot(audio_y);
    end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
    global audio_y;
    global audio_Fs;
    [filename, pathname] = uigetfile('.m4a', 'Seleccione el archivo de audio');
    [audio_y, audio_Fs] = audioread(strcat(pathname,filename));
    [audio_length, a] = size(audio_y);
    disp('Audio length (s):');
    disp(audio_length/audio_Fs);
    axes(handles.axes2);
    plot(audio_y);


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    global midi;
    [y,Fs] = midi2audio(midi);
    soundsc(y, Fs);  % FM-synth


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    global audio_y;
    global audio_Fs;
    soundsc(audio_y, audio_Fs);
    

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
    global audio_y;
    global audio_Fs;
    global midi;
    notes = midiInfo(midi,0);

    [rows, columns] = size(notes);

    new_y = [];
    audio_y_portion = [];
    last_note = 0.0;
    for i = 1:rows
        note_properties = [];
        % Lower the note down to the -4 octave (normal human voice register)
        notes(i, 3) = notes(i, 3) - 36;
        if last_note ~= notes(i, 3)  
            disp(notes(i,3));
            target_frecuency = midi2freq(notes(i,3));
            last_note = notes(i,3);
            start_time = notes(i,5)*2;
            end_time = notes(i,6)*2;
            sample_init = int32(audio_Fs* start_time)+1;
            sample_end = int32(audio_Fs* end_time)+1;
            % Create sub array with portion of audio according to the midi note
            % time
            audio_y_portion = audio_y(sample_init: sample_end);
            %plot(new_y_portion);
            xdft = fft(audio_y_portion);
            [~,index] = max(abs(xdft(1:length(audio_y_portion)/2)));
            disp('portion frecuency:');
            portion_frecuency = index / 10.0;
            disp(portion_frecuency);
            disp('target frecuency');
            disp(target_frecuency);
            disp('target factor');
            factor = target_frecuency/portion_frecuency;


            num_dig = 3;
            n_rounded = round(factor*(10^num_dig))/(10^num_dig);
            disp(n_rounded);
            % http://www.ee.columbia.edu/ln/labrosa/matlab/pvoc/
            [r_2, r_1] = numden(sym(n_rounded));
            r_1=double(r_1); r_2= double(r_2);
            disp([r_1,r_2]);
            extended = pvoc(audio_y_portion, r_1 / r_2);
            %disp('extended');
            %resample(x,p,q) resamples the input sequence, x, at p/q times the original sample rate
            shifted_sound = resample(extended, r_1, r_2); % NB: 0.8 = 4/5
            %disp('shifted');
            %disp(numel(f)/audio_Fs);
            %soundsc(shifted_sound, audio_Fs);
            %pause(0.5);
            xdft = fft(shifted_sound);
            [~,index_n] = max(abs(xdft(1:length(shifted_sound)/2+1)));
            disp('new frecuency:');
            disp( index_n / 10.0);

            new_y = [new_y; shifted_sound];
            disp('----------');

        end

    end;

    soundsc(new_y, audio_Fs);
