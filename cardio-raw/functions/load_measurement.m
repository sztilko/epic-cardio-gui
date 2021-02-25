function [WL_map,time]=load_measurement(dir)
    S = 0.0002; %the steepness of pixel wise calibration equation
    
    % load initial WL map
    fr = matlab.io.datastore.DsFileReader(strcat(dir,'\240x320x4x3_test_WL_Power'));
    init_map = read(fr,614400,'OutputType','single');
    init_wl_map = reshape(init_map(1:76800),[320 240])';
    
    % load intensity timesteps
    dirlist = ls(strcat(dir,'\DMR'));
    name_cell = cellstr(dirlist);
    sorted_files = natsortfiles(name_cell);
    %delete "." and ".." filenames
    sorted_files(1)=[]; 
    sorted_files(end)=[];
    
    timestep_mats = zeros(length(sorted_files),240,320); 
    for i=1:length(sorted_files)
%         i
        fr = matlab.io.datastore.DsFileReader(strcat(dir,'\DMR\',char(sorted_files(i))));
        A_int = read(fr,153600,'OutputType','uint16');
        timestep_mats(i,:,:) = reshape(reshape(A_int,[320 240])',[1 240 320]);
    end
    
    WL_map = permute(repmat(init_wl_map,[1,1,size(timestep_mats,1)]),[3,1,2]) +S*(timestep_mats-repmat(timestep_mats(1,:,:),[size(timestep_mats,1),1,1]));
    %read timestep information "from test_avg" file
    A = readmatrix('test_avg','NumHeaderLines',1,'DecimalSeparator',',');
    time = squeeze(A(2:end,1))*60; % skip first 0 value and convert to seconds
end
