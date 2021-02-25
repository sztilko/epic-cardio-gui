function VMask = segment2(maxX,maxY,image_size)
% Calculates segment mask if only 2 cells are detected on a sensor
% the segements are defined by the perpendicular bisector of the connecting
% line of the points

%Inputs: 
%   maxX - X-coordinates of the two points
%   maxY - Y-coordinates of the two points
%   image_size - size of the rectangular image in pixels
%Returns:
%   VMask - mask of 1s and 2s indicating the region of each cell

x = maxX;
y = maxY;

p1 = [x(1);y(1)];
p2 = [x(2);y(2)];

delta = (p2-p1);
rot_mat = [0,-1;1,0];
perp_vec = rot_mat*delta;

midpoint = p1 + 0.5*delta;

m = perp_vec(2)/perp_vec(1); %slope of boundary

boundary_line = @(x) m*(x-midpoint(1))+midpoint(2); %equation of boundary

VMask = NaN(image_size,image_size);
for im_x=1:image_size
    for im_y=1:image_size
        if im_y>boundary_line(im_x)
            VMask(im_x,im_y) =1;
        else
            VMask(im_x,im_y) =2;
        end
    end
end
%for correct orientation we need to flip the mask image
%(if I would be smarter I could define de function in a way that its already good orientation,
% but I dont really have time for that now... :) )
VMask = VMask';
end

