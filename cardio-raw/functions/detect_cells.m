function [max_coord,cellLabels,VMask,max_shift] = detect_cells(detection_th,pic,pix_size)
% Returns the max coordinates and the Voronoid tesselation of the image last frame of pic for given detection threshold (in pm).
% Input: 
%   detection_th - wavelength shift above which cells are detected
%   pic - the measurement data matrix
%   pix_size - pixel size in um (after interpolation)
% Returns:
%   max_coord - x,y coordinates of detected cells in shape: [number of cells, 2]
%   cellLabels - labels of cells
%   VMask - Voronoi tesselation of the frame, containing cell labels in each assigned Voronoi cell. shape [pix_size,pix_size]
%   max_shift - maximal wavelength shift of cells on the last frame

%minimal distance between neighbour cells (um).
mindist=75; %Change this value if needed!
% mindist=0; %Change this value if needed!

%distance from sides of the image to exclude maxima (um).
bandwidth = 50; %Change this value if needed!
% bandwidth = 0; %Change this value if needed!

x=pic(:,:,end); %last frame of measurement

%find maxima on last frame
max_coord_lin=findmax_banded(x,mindist,bandwidth,pix_size); %keeps 50um from edges for max detection
max_coord_lin(x(max_coord_lin)<detection_th)=[];    %throw away maxima with WS lower than threshold
[maxY,maxX]=ind2sub(size(pic),max_coord_lin);
max_coord=[maxX,maxY];
cellLabels=1:size(max_coord,1);
max_shift=x(max_coord_lin); %maximum shifts on last frame

intim_size=size(x,1);
ext_limit=[0 0 intim_size intim_size 0;0 intim_size intim_size 0 0]'; %define image bounds for VoronoiLimit
if ~isempty(maxX) && ~isempty(maxY)
    if size(maxX,1)>=3
        %in case three or more cells are detected
        [V,C,~]=VoronoiLimit(maxX,maxY,'bs_ext',ext_limit,'figure','off');
        VMask=zeros(intim_size); %initializing mask tensor with zeros in the same size as interpolatied tensor
        for i=1:size(max_coord,1)
            mask=poly2mask(V(C{i},1),V(C{i},2),intim_size,intim_size);
            VMask(mask)=i; %filling mask tensor with numbers associated with single cells
        end
        disp(strcat('number of detected cells:',num2str(size(maxX,1))));
    elseif size(maxX,1)==2
        %in case two cells are detected
        disp('number of detected cells: 2');
        VMask = segment2(maxX,maxY,intim_size);
        
    elseif size(maxX,1)==1
        %in case a single cell is detected
        VMask = ones(intim_size,intim_size);
        disp('number of detected cells: 1');
    elseif isempty(maxX)
        %in no cells are detected
        VMask = zeros(intim_size,intim_size);
        disp('number of detected cells: 0');
    end
end

end

