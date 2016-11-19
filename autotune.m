[filename, pathname] = uigetfile('.mid', 'Seleccione el archivo midi');
midi = readmidi(strcat(pathname,filename));
% synthesize with FM-synthesis.
% (y = audio samples.  Fs = sample rate.  Here, uses default 44.1k.)
% sprintf(midi);
[y,Fs] = midi2audio(midi);
%soundsc(y, Fs);  % FM-synth
notes = midiInfo(midi,0);%
% compute piano-roll:
disp(notes);
[PR,t,nn] = piano_roll(notes);
%display piano-roll:
figure;
imagesc(t, nn, PR);
axis xy;
xlabel('time (sec)');
ylabel('note number');

% track number
% channel number
% note number (midi encoding of pitch)
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
            note_properties = [note_properties notes(i,j)];
        end;
        if j == 5
            % Start time
            %append(note_properties,notes(i,j));
            note_properties = [note_properties notes(i,j)];
        end;
        if j == 6
            % end time
            %append(note_properties,notes(i,j));
            note_properties = [note_properties notes(i,j)];
        end;
	end;
    all_notes = [all_notes note_properties];
    %disp(note_properties);
	%disp('---------');
end;
% for elm = notes
% 	disp(elm);
% end