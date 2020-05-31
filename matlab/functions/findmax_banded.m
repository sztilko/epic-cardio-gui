function maxCoord = findmax_banded(frame,minDist,bandwidth,thpix)
%find maxima on a 'thresholded picture'(which is 0 on below threshold areas)
%the region ignored for maxima search around edges of the image is given by the bandwidth factor
% Input: 
%   frame - a frame of measurement at given timestep to do cell detection
%   minDist - minimum distance between detected maxima (um)
%   bandwidth - width of exclusion zone for maxima detection measured from the sides of the image (um)
%   thpix - pixel size in um (after interpolation)
% Returns:
%   maxCoord - linear indexes/coordinates of detected maxima

minDist_pix=round(minDist/thpix);   %convert minDist to pixels
se = ones(minDist_pix);             %structuring element for dilating
% se = [0,1,0;1,1,1;0,1,0];
FRAME = imdilate(frame,se);         %dilated frame
maxCoord=find(frame == FRAME);      %places where the dilated frame is same as the original one are extremum
maxCoord(frame(maxCoord)==0)=[];    %drop minima

[maxY,maxX]=ind2sub(size(frame),maxCoord);  %convert linear index to subscript

bandwidth_pix=round(bandwidth/thpix);   %convert bandwidth to pixels
pic_size=size(frame,1);
iout=[];
%drop maxima that are in the exclusion zone
for i=1:size(maxX,1)
    if maxX(i)<bandwidth_pix || maxX(i)>(pic_size-bandwidth_pix)
        iout=[iout;i];
    end
    if maxY(i)<bandwidth_pix || maxY(i)>(pic_size-bandwidth_pix)
        iout=[iout;i];
    end 
end
iout=unique(iout);
maxXfilt=maxX(setdiff(1:size(maxY,1),iout));
maxYfilt=maxY(setdiff(1:size(maxY,1),iout));

maxCoord = sub2ind(size(frame), maxYfilt, maxXfilt); %convert subscript to linear index
end

