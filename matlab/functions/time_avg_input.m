function time_avg_input(file)
% If the cardio data is not averaged in time (multiple rows for the same timestep),
% this function calculates it and writes averaged format file (single row for the same timestep).
% Input: 
%   file in .xlsx format with the dimensions: T by (1+n*n) , where
%   T is the recorded(unaveraged) timesteps,
%   n is the size of the rectangular sensor area in pixels,
%   (+1 is the first column of timestep entries)
% Returns: None 

disp(strcat('Input file "',file,'" is not time-averaged! Creating averaged file...'));
datafile=xlsread(file);
time=datafile(:,1);
tmp=datafile(1,:);
j=1;
k=1;
for i=2:size(time,1)
    if time(i)==time(i-1)
        tmp=tmp+datafile(i,:);
        k=k+1;
    elseif i==size(time,1)
        timeavg_datafile(j+1,:)=datafile(i,:);
    else
        timeavg_datafile(j,:)=tmp./k;
        j=j+1;
        tmp=datafile(i,:);
        k=1;

    end
end
disp(strcat('New averaged file: ',strrep(file,'.xlsx','_timeavg.xlsx')));
xlswrite(strrep(file,'.xlsx','_timeavg.xlsx'),timeavg_datafile);

end

