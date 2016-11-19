%[filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
%midi = readmidi(strcat(pathname,filename));
midi = readmidi('midi/base_de_prueba.mid');
[audio_y, audio_Fs] = audioread('audio/rec.m4a');
[audio_length, a] = size(audio_y);
disp('Audio length (s):');
disp(audio_length/audio_Fs);
% sound(y,Fs);
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
for i = 1:rows
    note_properties = [ ];
	for j = 1:columns
        if j == 3
            % pitch
            %append(note_properties, notes(i,j));
            note_frecuency = midi2freq(notes(i,j));
            note_properties = [note_properties note_frecuency];
        end;
        if j == 5
            % Start time
            %append(note_properties,notes(i,j));
            note_properties = [note_properties notes(i,j)*2];% *2 just to make it longer
        end;
        if j == 6
            % end time
            %append(note_properties,notes(i,j));
            note_properties = [note_properties notes(i,j)*2];% *2 just to make it longer
        end;
    end
%     disp('..')
%     disp(audio_length)
%     disp('..')
%     disp(audio_Fs)
%     disp('..')
%     disp(note_properties(2))
    sample_init = audio_Fs* note_properties(2);
    sample_end = audio_Fs* note_properties(3);
    %disp(sample_init);
    %disp(note_properties(2));
    % Create sub array with portion of audio according to the midi note
    % time
    %new_y = audio_y(sample_init:sample_end);
    
    all_notes = [all_notes note_properties];
    %disp(all_notes);
	%disp('---------');
end;
sound(new_y,Fs);
% for i = 1:rows
%     for j =1:3
%         disp(all_notes(i,j));
%     end
%     disp('---------');
% end
