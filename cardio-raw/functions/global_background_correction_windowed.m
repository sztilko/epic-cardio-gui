function corrected_pic = global_background_correction_windowed(pic,th_mean, th_width)
%corrects whole measurement by calculating background mask based on a given threshold on the last frame
%the measurement is then corrected by the average of inverse mask areas (ideally the areas that did not contain cells)
% Input: 
%   pic - the original(uncorrected) measurement data matrix
%   threshold - threshold level that separates cell region from background region on the last frame (pic(:,:,end))
% Returns:
%   corrected_pic - the corrected signal matrix

last_frame = squeeze(pic(:,:,end));
BGarea = (last_frame>th_mean-th_width/2) & (last_frame<th_mean+th_width/2);
baseline = BGarea.*pic;

%calculate average background signal
baseline_avg = zeros(size(pic,3),1);
for i=1:size(pic,3)
    baseline_avg(i)=mean(nonzeros(baseline(:,:,i)));
end

%background average correction matrix
baseline_mtx = zeros(size(pic));
for i=1:size(pic,3)
	baseline_mtx(:,:,i)=repmat(baseline_avg(i),size(pic,1:2));
end

%correct data with baseline
corrected_pic = pic-baseline_mtx;

end

