function pic_corr = linear_baseline_correction(start_time,end_time,avgWS,pic,time)
%Calculates the corrected measurement data from given linear baseline section
% Input: 
%   start_time - start of linear fit data
%   end_time - end of linear fit data
%   avgWS - spatially averaged signal of the measurement
%   pic - the original(uncorrected) measurement data matrix
%   time - time vector
% Returns:
%   pic_corr - the linearly corrected signal matrix

img_size=size(pic,1);
end_time=find(time>=end_time,1);

if start_time==0    %just to be sure user wont input 0 index...
	start_time=1;
else
    start_time=find(time<=start_time,1,'last');
end

v_base=avgWS(start_time:end_time)';
time_base=time(start_time:end_time);

%construct baseline matrix for video
baseline_mat=zeros(img_size,img_size,size(time,1));

%fit linear baseline to data
lin_param = polyfit(time_base,v_base,1);

%create baseline matrix with data from linear fit
for i=1:size(time,1)
    baseline_mat(:,:,i)=repmat(time(i)*lin_param(1)+lin_param(2),img_size,img_size);
end

%correct data with baseline
pic_corr=pic-baseline_mat;
end

