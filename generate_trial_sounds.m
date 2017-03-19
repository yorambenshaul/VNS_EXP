<<<<<<< HEAD
function [apply_sound clean_sound  end_sound] = generate_trial_sounds(SR)
% generate sounds for queing the user for stimulus application 
% YBS 2017


% Define the sound segment lengths
% Sound factors for all sound waveforms generated
sound_amp    = 5;
sound_offset = 0;
% apply sound parameters
apply_sound_dur_per_step = 1;
apply_sound_freq = 2*[130.81 146.83 164.81 174.61 196 220 246.94 261.63];

% generate initial sound signal
apply_sound = [];
duration = apply_sound_dur_per_step * ones(size(apply_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(apply_sound_freq)
    samps_per_cycle = floor(SR/apply_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    apply_sound = [apply_sound   repmat(one_cycle,[1  ceil(cycles_per_second*duration(i))])  ];
end
% to shift voltage so that INTAN board can read it
apply_sound = sound_amp*apply_sound + sound_offset;

% clean sound parameters
clean_sound_duration = 0.5;
clean_sound_freq = fliplr(apply_sound_freq);
clean_sound = [];
duration = clean_sound_duration * ones(size(clean_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(clean_sound_freq)
    samps_per_cycle = floor(SR/clean_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    clean_sound = [clean_sound   repmat(one_cycle,1,ceil(cycles_per_second*duration(i)))];
end
clean_sound = sound_amp*clean_sound +sound_offset;

% End of trial sound
end_sound_duration = 0.1;
end_sound_freq = fliplr(2 * [130.81 146.83 164.81 174.61 196 ]);
end_sound_signal = [];
duration = end_sound_duration * ones(size(end_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(end_sound_freq)
    samps_per_cycle = floor(SR/end_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    end_sound_signal = [end_sound_signal   repmat(one_cycle,[1  ceil(cycles_per_second*duration(i))]) ];
end
end_sound = sound_amp*end_sound_signal + sound_offset;

=======
function [apply_sound clean_sound  end_sound] = generate_trial_sounds(SR)
% generate sounds for queing the user for stimulus application 
% YBS 2017


% Define the sound segment lengths
% Sound factors for all sound waveforms generated
sound_amp    = 5;
sound_offset = 0;
% apply sound parameters
apply_sound_dur_per_step = 1;
apply_sound_freq = 2*[130.81 146.83 164.81 174.61 196 220 246.94 261.63];

% generate initial sound signal
apply_sound = [];
duration = apply_sound_dur_per_step * ones(size(apply_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(apply_sound_freq)
    samps_per_cycle = floor(SR/apply_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    apply_sound = [apply_sound   repmat(one_cycle,[1  ceil(cycles_per_second*duration(i))])  ];
end
% to shift voltage so that INTAN board can read it
apply_sound = sound_amp*apply_sound + sound_offset;

% clean sound parameters
clean_sound_duration = 0.5;
clean_sound_freq = fliplr(apply_sound_freq);
clean_sound = [];
duration = clean_sound_duration * ones(size(clean_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(clean_sound_freq)
    samps_per_cycle = floor(SR/clean_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    clean_sound = [clean_sound   repmat(one_cycle,1,ceil(cycles_per_second*duration(i)))];
end
clean_sound = sound_amp*clean_sound +sound_offset;

% End of trial sound
end_sound_duration = 0.1;
end_sound_freq = fliplr(2 * [130.81 146.83 164.81 174.61 196 ]);
end_sound_signal = [];
duration = end_sound_duration * ones(size(end_sound_freq)); % in seconds %duration = [1 0.5 1 1 1 0.5 0.2 0.5 1]
for i = 1:length(end_sound_freq)
    samps_per_cycle = floor(SR/end_sound_freq(i));
    one_cycle = sin(linspace(0, 2*pi, samps_per_cycle));
    cycles_per_second = SR/length(one_cycle);
    end_sound_signal = [end_sound_signal   repmat(one_cycle,[1  ceil(cycles_per_second*duration(i))]) ];
end
end_sound = sound_amp*end_sound_signal + sound_offset;

>>>>>>> origin/master
