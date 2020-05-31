function formatted_data = format_export(data,cell_labels,time)
%The function gets input data in the raw export format of rows as different cells data, and cols as data timesteps
%The current formatted output attaches cell labels(as read from CardioGUI) to the first column, and attaches real time(in seconds) as the first row
% Input: 
%   data - matrix with shape [len(cellIDs),len(time)] containing the data to be exported ('maxWS', 'IWS', 'avgWS', 'area' modalities)
%   cell_labels - cellIDs of selected cells
%   time - time vector
% Returns:
%   formatted_data (see format below...)
data=[cell_labels,data];
formatted_data=[0,time';data];
end
