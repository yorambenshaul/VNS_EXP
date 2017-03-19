<<<<<<< HEAD
function Stimuli = read_stimulus_file(fname)
% Read stimuli from stimulus file and return as char array

fid = fopen(fname,'r');

k = 0;
while 1
    tline = fgetl(fid); % This is the file name line
    if ~ischar(tline), break, end    
    if ~isempty(tline) % ignore empty lines
        k = k + 1;
        Stimuli{k} = tline;        
    end
end


=======
function Stimuli = read_stimulus_file(fname)
% Read stimuli from stimulus file and return as char array

fid = fopen(fname,'r');

k = 0;
while 1
    tline = fgetl(fid); % This is the file name line
    if ~ischar(tline), break, end    
    if ~isempty(tline) % ignore empty lines
        k = k + 1;
        Stimuli{k} = tline;        
    end
end


>>>>>>> origin/master
fclose(fid);