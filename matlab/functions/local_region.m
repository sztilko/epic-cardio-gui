function th_mesh = local_region(point,radius,pic_size,raw_pix_size)
%Inputs: 
%   point - 2 element vector (x_coord,y_coord)
%   radius - radius of ROI circle in um (effectively will be multiples of raw_pix_size)
%   pic_size - size of the input square(!) image (single number)
%Returns:
%   th_mesh - the binary circular region with given radius of the target point on mesh area

radius = round(radius/raw_pix_size); %convert radius in um to pixel distance

[X,Y] = meshgrid(1:pic_size) ; %create mesh

%generate points of the circle
th = linspace(0,2*pi) ;
xc = point(1)+radius*cos(th) ; 
yc = point(2)+radius*sin(th) ;

%create mask of ones if the mesh pixel is inside the circle
th_mesh = zeros(size(X)) ;
idx = inpolygon(X(:),Y(:),xc,yc) ;
th_mesh(idx) = 1 ;
end

