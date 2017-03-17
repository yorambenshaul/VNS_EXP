function [SOUND_chan,VNO_chan,VALVE_chan ] = generate_single_SNT_stim_scan(Params)
% Generate a single SNT stimulation train

% param fields are
% SR sampling rate in Hz
SR = Params.SR;

samples_VNO_stim_duration            = Params.VNO_stim_duration * SR;
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
VNO_stim_train = [VNO_stim_train(1:(end-5)) zeros(1,5)];


trial_ints(1) = samples_VNO_stim_duration;


SOUND_chan  =  0*ones(1,sum(trial_ints(1)))   ;
VNO_chan   =  VNO_stim_train  ;
VALVE_chan = 0*ones(1,sum(trial_ints(1))) ;


