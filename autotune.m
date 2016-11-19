%[filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
%midi = readmidi(strcat(pathname,filename));
midi = readmidi('midi/base_de_prueba.mid');
[audio_y, audio_Fs] = audioread('audio/rec.m4a');
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
new_y_portion = [];
last_note = 0.0;
for i = 1:rows
    note_properties = [ ];
    if last_note ~= notes(i, 3)
        note_frecuency = midi2freq(notes(i,3));
        last_note = notes(i,3);
        start_time = notes(i,5)*2;
        end_time = notes(i,6)*2;
        sample_init = int32(audio_Fs* start_time)+1;
        sample_end = int32(audio_Fs* end_time)+1;
        % Create sub array with portion of audio according to the midi note
        % time
        new_y_portion = audio_y(sample_init: sample_end);
        sound(new_y_portion,Fs);
        pause(0.5);
    end
end;

