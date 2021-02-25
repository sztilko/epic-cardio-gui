function calib_table = th_opt(calib_table,comparison_frame,voronoi_mask,max_steps,intpix)
% imagesc(voronoi_mask);
%tolerance of optimization: accepted deviation from the true area given as the percentage of true area
eps = 0.01;
% iterate over calib cells : i
for i=1:size(calib_table,1)
    % do calibration in voronoi cell
    cell_id = str2num(cell2mat(calib_table(i,1)))
    calib_cell = comparison_frame.*(voronoi_mask==cell_id);

%     figure();
%     imagesc(calib_cell);

    % define initial threshold : th0
    th0 = max(calib_cell(:))*0.5;
    
    %get true area from calibration table
    true_area = cell2mat(calib_table(i,2));

    % threshold image
    th_area=nnz(calib_cell>th0)*intpix*intpix;

    %Newton method for correct threshold
    % step size for Newton method's derivative calculation
    thD=3;

    
    th_new=th0;
    j=0;
    %calculate next candidate
    th_store=[];
    area_store=[];
    while (abs(true_area-th_area)/true_area > eps) && (j<max_steps)
        j=j+1;
        th_store(j)=th_new;
        th_area=nnz(calib_cell>th_new)*intpix*intpix;
        
        th_area_DR=nnz(calib_cell>(th_new+thD))*intpix*intpix;
        grad_right = ((th_area-th_area_DR)/thD);
        th_area_DL=nnz(calib_cell>(th_new-thD))*intpix*intpix;
        grad_left = -1*((th_area-th_area_DL)/thD);
        
        grad = grad_right+grad_left/2;
        th_new=th_new-(true_area-th_area)/grad;
        %if overshoot happens set threshold to 95% of max (which will probably undershoot area)
        if th_new>max(calib_cell(:))
            th_new=th0*0.80;
        end

        th_area=nnz(calib_cell>th_new)*intpix*intpix;
        area_store(j)=th_area;
    end
%     figure()
%     plot(th_store);

%     plot(area_store);
%     title(num2str(cell_id))
    calib_table(i,5)=num2cell(th_new);
    calib_table(i,4)=num2cell(th_area);
end

