<<<<<<< HEAD
function [SOUND_chan,VNO_chan,VALVE_chan]=generate_single_washvalve_scan(valveState)
% open and close the valve - simply changing output level
% YBS - 2017

digoutV = 3.3;

if  strcmp(valveState,'close')
    samples_valve_duration=ones(1,100);
elseif strcmp(valveState,'open')
    samples_valve_duration=zeros(1,100);
end
SOUND_chan  =  0*samples_valve_duration   ;
VNO_chan   =  0*samples_valve_duration  ;
VALVE_chan = samples_valve_duration*digoutV ;

=======
function [SOUND_chan,VNO_chan,VALVE_chan]=generate_single_washvalve_scan(valveState)
% open and close the valve - simply changing output level
% YBS - 2017

digoutV = 3.3;

if  strcmp(valveState,'close')
    samples_valve_duration=ones(1,100);
elseif strcmp(valveState,'open')
    samples_valve_duration=zeros(1,100);
end
SOUND_chan  =  0*samples_valve_duration   ;
VNO_chan   =  0*samples_valve_duration  ;
VALVE_chan = samples_valve_duration*digoutV ;

>>>>>>> origin/master
