%[filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
%midi = readmidi(strcat(pathname,filename));
midi = readmidi('midi/base_de_prueba.mid');
[audio_y, audio_Fs] = audioread('audio/rec_one_2_ten.m4a');
[audio_length, a] = size(audio_y);
disp('Audio length (s):');
disp(audio_length/audio_Fs);
%sound(audio_y,audio_Fs);
% synthesize with FM-synthesis.
% (y = audio samples.  Fs = sample rate.  Here, uses default 44.1k.)
% sprintf(midi);
[y,Fs] = midi2audio(midi);
% soundsc(y, Fs);  % FM-synth
notes = midiInfo(midi,0);%
% compute piano-roll:
%disp(notes);
[PR,t,nn] = piano_roll(notes);
%display piano-roll:
figure;
imagesc(t, nn, PR);
axis xy;
xlabel('time (sec)');
ylabel('note number');

% track number
% channel number
% note number (midi encoding of pitch) http://tonalsoft.com/pub/news/pitch-bend.aspx
% velocity
% start time (seconds)
% end time (seconds)
% message number of note_on
% message number of note_off

[rows, columns] = size(notes);

all_notes = [];
new_y = [];
audio_y_portion = [];
last_note = 0.0;
for i = 1:rows
    note_properties = [ ];
    % Lower the note down top the -5 octave
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
        soundsc(shifted_sound, audio_Fs);
        pause(0.20);
        xdft = fft(shifted_sound);
        [~,index_n] = max(abs(xdft(1:length(shifted_sound)/2+1)));
        disp('new frecuency:');
        disp( index_n / 10.0);
        
        %new_y = [new_y shifted_sound];
        disp('----------');
        
    end
    
end;

%soundsc(new_y, Fs);