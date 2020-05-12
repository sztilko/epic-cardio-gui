function [pic,time,img_size] = load_data(file)
%Reads in datafile to create the 3D data structure of measurement
%Inputs:
%   file in .xlsx format with the dimensions: [T, (1+n*n)] , where
%   T is the number of timesteps,
%   the first column contains the timestep entries,
%   n is the size of the rectangular sensor area in pixels,
%Returns:
%   pic - 3D structured data in shape of : [image_size,image_size,len(time)], containing the pixel-wise measurements 
%   time - vector containing timesteps
%   img_size - size of a side of the sensor image in pixels

% data=xlsread(file);
% data=readmatrix(file);

%faster approach
data_table=readtable(file,'basic',true);
data = data_table{:,:};

if size(data(:,1),1)~=size(unique(data(:,1)),1)
    time_avg_input(file);
    data=xlsread(strrep(file,'.xlsx','_timeavg.xlsx'));
end
    
time=data(:,1); %get time from first column
data(:,1) = []; %delete first column (time) from data
if floor(sqrt(size(data,2)))==sqrt(size(data,2))
    img_size=sqrt(size(data,2));
else
    error('Selected biosensor area is not rectangular!');
end
data(isnan(data))=0; % handle NaNs

pic=zeros(img_size,img_size,size(time,1)); %initialization of video matrix
for i=1:size(time,1)
    pic(:,:,i)=reshape(data(i,:),[img_size,img_size]);
end
pic=permute(pic,[2 1 3]); %permutation needed to get back original orientation of the matrix
end

