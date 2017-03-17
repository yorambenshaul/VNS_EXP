function [SOUND_chan,VNO_chan,VALVE_chan apply_sample] = generate_single_VNS_trial_scan(Params)
% Generate output signals according to selected trial parameters
% YBS 2017

% param fields are
% SR sampling rate in Hz
SR = Params.SR;
digoutV = 3.3; % scale factor for the valve channel


[apply_sound,clean_sound, end_sound] = generate_trial_sounds(SR);

samples_apply_sound = length(apply_sound);
samples_clean_sound = length(clean_sound);
samples_end_sound   = length(end_sound);
samples_ES_stim_to_apply_delay = 0; % Params.ES_stim_to_apply_delay * SR;
samples_ES_stim_duration       = 0; % Params.ES_stim_duration * SR;
samples_application_to_stim_delay    = Params.application_to_stim_delay * SR;
samples_ES_stim_to_VNO_stim_delay     = 0; % Params.ES_stim_to_VNO_stim_delay * SR;
samples_VNO_stim_duration             = Params.VNO_stim_duration * SR;
samples_stim_to_wash_delay            =  Params.stim_to_wash_delay * SR;
samples_wash_start_to_wash_stim_delay = Params.wash_start_to_wash_stim_delay * SR;
samples_wash_stim_to_wash_end_delay   = Params.wash_stim_to_wash_end_delay * SR;

apply_sample = samples_apply_sound;


%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate VNO stimulation train
VNO_period_samples = ceil(SR / Params.VNO_stim_frequency) ;% in samples
VNO_n_cycles = ceil(samples_VNO_stim_duration/VNO_period_samples);
% positive, inter and negative pulse times in samples:
VNO_ps  = ceil(SR*Params.VNO_stim_pulse_width/1000);
VNO_ips = ceil(SR*Params.VNO_stim_interphase_delay/1000);
VNO_samples_per_pulse = 2*VNO_ps + VNO_ips;
VNO_samples_between_pulses = VNO_period_samples - VNO_samples_per_pulse;
VNO_one_pulse = [zeros(1,VNO_samples_between_pulses) -Params.VNO_stim_amplitude*ones(1,VNO_ps) zeros(1,VNO_ips) Params.VNO_stim_amplitude*ones(1,VNO_ps)];
VNO_stim_train = repmat(VNO_one_pulse,1,VNO_n_cycles);
VNO_stim_train = VNO_stim_train(1:samples_VNO_stim_duration);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate ES external stimulation train
ES_stim_train = [];


trial_ints(1) = samples_apply_sound - samples_ES_stim_to_apply_delay;
trial_ints(2) = samples_ES_stim_to_apply_delay;
trial_ints(3) = samples_ES_stim_duration - samples_ES_stim_to_apply_delay;
trial_ints(4) = samples_application_to_stim_delay - samples_ES_stim_to_VNO_stim_delay - trial_ints(3);
trial_ints(5) = samples_ES_stim_to_VNO_stim_delay;
trial_ints(6) = samples_VNO_stim_duration;
trial_ints(7) = samples_ES_stim_duration - trial_ints(5) - trial_ints(6);
trial_ints(8) = samples_stim_to_wash_delay - trial_ints(7) - trial_ints(6) - samples_clean_sound;
trial_ints(9) = samples_clean_sound;
trial_ints(10) = samples_wash_start_to_wash_stim_delay;
trial_ints(11) = samples_VNO_stim_duration;
trial_ints(12) = samples_wash_stim_to_wash_end_delay - samples_VNO_stim_duration;
trial_ints(13) = samples_end_sound;



SOUND_chan  = [apply_sound zeros(1,sum(trial_ints([3:8])))  clean_sound zeros(1,sum(trial_ints([10:12]))-samples_end_sound)   end_sound zeros(1,sum(trial_ints([13])))] ;
VNO_chan   = [zeros(1,sum(trial_ints([1:5]))) VNO_stim_train zeros(1,sum(trial_ints([7:10])))  VNO_stim_train zeros(1,sum(trial_ints([12:13])))] ;
VALVE_chan = [zeros(1,sum(trial_ints([1:9]))) digoutV * ones(1,sum(trial_ints([10:12]))) zeros(1,sum(trial_ints([13])))];


