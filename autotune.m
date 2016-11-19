%[filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
%midi = readmidi(strcat(pathname,filename));
midi = readmidi('midi/base_de_prueba.mid');
[audio_y, Fs] = audioread('audio/rec.m4a');
[lenght_audio, a] = size(audio_y);
disp('Audio length (s):');
disp(lenght_audio/Fs);
%new_y = 
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
	end;
    all_notes = [all_notes note_properties];
    %disp(all_notes);
	disp('---------');
end;
% for i = 1:rows
%     for j =1:3
%         disp(all_notes(i,j));
%     end
%     disp('---------');
% end
