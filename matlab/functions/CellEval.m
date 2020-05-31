function data = CellEval(pic,VMask,time,thpix,uniqueTH,selected_cells,fig)
% Calculates single cell data
% Input: 
%   pic - the measurement data matrix
%   VMask - Voronoi tesselation of the last frame, containing cell labels in each assigned Voronoi cell. shape [pix_size,pix_size]
%   time - time vector
%   thpix - pixel size in um (after interpolation)
%   uniqueTH - thresholds associated with each cell (either unique values(unique thresholding) or same(global thresholding))
%   selected_cells - cellsID of cells selected as targets for evaluation
%   fig - figure window of the CardioAlpha app
% Returns:
%   data - struct with fields [WS_avgs,AREAs,AREAs_corr,IWS,IWS_corr,maxWS]. Each struct element contains data in the shape of [number of cells, timesteps]

% data fields:
%   maxWS - maximum signals of cell in each timestep
%   AREAs - area of cell in each timestep
%   AREAs_corr - corrected area of cell in each timestep (correction applied to early timesteps)
%   WS_avgs - average WS of the whole cell in each timestep
%   IWS - integrated wavelength shift: AREAs_corr * WS_avgs
%   IWS_corr - corrected IWS (correction applied to early timesteps)
%   cTH - corresponding/unique threshold of each cell

%creating progress bar
f = fig;
d = uiprogressdlg(f,'Title','Please Wait','Message','Evaluating data...');

%initializing
cellNum=size(selected_cells,1);
signal=zeros(size(pic));
IWSs=zeros(cellNum,size(time,1));
AREAs=zeros(cellNum,size(time,1));
AREAs_corr=zeros(cellNum,size(time,1));
WS_avgs=zeros(cellNum,size(time,1));
maxWS=zeros(cellNum,size(time,1));
IWS_corr=zeros(cellNum,size(time,1));

t=0;
for i=selected_cells'
    tic
    t=t+1;
    segment=pic.*(VMask==i);            %gives back the voronoi segment of given cell (3D signal)
    th_segment=segment>=uniqueTH(i);    %thresholds inside segment, based on unique threshold  (3D binary)
    [~,~,fnt]=ind2sub(size(pic),find(th_segment,1)); %fnt=first nonzero timestep
    static_frame=th_segment(:,:,fnt);   %gives back the first nonzero frame
    
    signal(:,:,1:fnt)=pic(:,:,1:fnt).*static_frame;  %the first part of the signal image
    signal(:,:,fnt+1:end)=pic(:,:,fnt+1:end).*th_segment(:,:,fnt+1:end); %the second part of the signal image    
    for j=1:size(time,1)
        tmp=nonzeros(signal(:,:,j));    %above threshold pixel values in given timestep
        tmp_max=squeeze(segment(:,:,j));%full signal of cell specific voronoi cell for max signal correction...
        
        %handle negative values in maxWS (however they should be avoided by proper baseline correction...)
        if (max(tmp_max(:))==0) && (sum(tmp_max(:))~= 0)
            maxWS(t,j) = max(tmp_max(tmp_max(:)~=max(tmp_max(:)))); %select max from nonzero elements
        else
            maxWS(t,j)=max(tmp_max(:));                %max WS values of single cells
        end
        
        %simplest handling of zero frames... check out its origin later!
        if isempty(tmp)     
%             try
%                 if j>1
%                     %use previous timesteps value
%                     maxWS(t,j)=maxWS(t,j-1);
%                 end
%             catch
%                 %if previous method fails use zero
%                 maxWS(t,j)=0;
%             end
            continue
        end
        
%         if isempty(tmp)
%             tmp=tmp_prev;       %to tackle the problem of 0s after fnt
%         end
%         tmp_prev=tmp;

        IWSs(t,j)=thpix*thpix*sum(tmp);      %surface integral of cell
        AREAs(t,j)=thpix*thpix*size(tmp,1); %surface of the cell
        WS_avgs(t,j)=IWSs(t,j)/AREAs(t,j);   %avgWS over single cell        
    end
    %fnat: first nonzero area timepoint-this selects the first timepoint when the area of a cell is a single noninterpolated pixel size (625um^2)
    fnat=find(AREAs(t,:)>=625);
    %if the cell never reaches 625um^2 area, use the fnt based area correction
    if isempty(fnat)
        AREAs_corr(t,1:fnt)=AREAs(t,1:fnt).*maxWS(t,1:fnt)./uniqueTH(i);
        AREAs_corr(t,fnt+1:end)=AREAs(t,fnt+1:end);
    end

    if ~isempty(fnat)
        AREAs_corr(t,1:fnat)=625*maxWS(t,1:fnat)./uniqueTH(i);
        AREAs_corr(t,fnat+1:end)=AREAs(t,fnat+1:end);
    end

    IWS_corr(t,:)=AREAs_corr(t,:).*WS_avgs(t,:);
    
    T1=toc;
    d.Value=t/cellNum;
    d.Message=['Evaluating data...Estimated time left: ',strcat(num2str(T1* (cellNum-t),'%.0f'),'s')];
end

data.WS_avgs=WS_avgs;
data.AREAs=AREAs;
data.IWS=IWSs;
data.AREAs_corr=AREAs_corr;
data.IWS_corr=IWS_corr;
data.maxWS=maxWS;
data.cTH=uniqueTH;

close(d);
end

