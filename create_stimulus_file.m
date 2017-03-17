function create_stimulus_file
% Generate stimulus files for SNT experiment

%%%%%%%%%%%%%%%%%
N_blocks = 3; % Number of blocks to calculate
% EXP_TYPE = 'exp_1'; % 
EXP_TYPE = 'exp_2'; % 


% Define the stimuli in each experiment - In each block (of the N_blocks)
% we will have each stimulus once, in a pseudorandom order
% switch statement for experiment type
switch EXP_TYPE  
    case 'exp_1'
        Stimuli{1} = 'MU_1';
        Stimuli{2} = 'MU_2';
        Stimuli{3} = 'MU_3';
        Stimuli{4} = 'FU_1';
        Stimuli{5} = 'FU_2';
        Stimuli{6} = 'FU_3';                
    case 'exp_2'
        Stimuli{1} = 'PU_1';
        Stimuli{2} = 'PU_2';
        Stimuli{3} = 'PU_3';
        Stimuli{4} = 'MU_1';
        Stimuli{5} = 'MU_2';
        Stimuli{6} = 'MU_3';    
        Stimuli{7} = 'FU_1';
        Stimuli{8} = 'FU_2';
        Stimuli{9} = 'FU_3';    
end

[BASE_P,~,~] = fileparts(mfilename('fullpath'));
STIM_FILE_PATH     = [BASE_P filesep 'stimulus_files'];
if ~exist(STIM_FILE_PATH,'dir')
    mkdir(STIM_FILE_PATH);
end
datestring = datestr(now,1); 
fname = [STIM_FILE_PATH  filesep 'stimfile_' datestring '.txt'];



if exist(fname,'file')
    ButtonName=questdlg('File exists, overwrite?', ...
        'make pseudo file', ...
        'No','Yes','No');
    switch ButtonName
        case 'No'
            return
    end % switch
end


fid = fopen(fname,'w');

% shuffle the random number generator (to avoid repeats in different MATLAB sessions)
rng('shuffle')

% Write stimuli to file
for i = 1:N_blocks
    ords = randperm(length(Stimuli));    
    for j = 1:length(ords)
        fprintf(fid,'%s\r\n',Stimuli{ords(j)});
    end
    fprintf(fid,['\r\n\r\n']);
end


fclose(fid);

return





