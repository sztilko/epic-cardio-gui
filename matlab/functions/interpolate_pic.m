function [intpic,intpix] = interpolate_pic(k,pic,raw_pix_size)
%Apply linear interpolation to data
% Input: 
%   k - interpolation degree (0-for no interpolation, k>0 for interpolation)
%   pic - the measurement data matrix
%   raw_pix_size - raw  pixel size of the biosensor instrument in um
% Returns:
%   intpic - linear indexes/coordinates of detected maxima
%   intpix - interpolated pixel size in um

n=size(pic,1);
time_size=size(pic,3);
intpix=raw_pix_size*n/(n+(n-1)*(2^k-1)); %this is a derived equation for the problem...
intpic=zeros(n+(n-1)*(2^k-1),n+(n-1)*(2^k-1),time_size); %initialize interpolated data

for i=1:time_size
    intpic(:,:,i)=interp2(pic(:,:,i),k);
end

end

