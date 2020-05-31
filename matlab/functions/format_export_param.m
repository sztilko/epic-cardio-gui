function format_export_param(data,data_filename,cell_IDs,data_type)
%Writes formatted output of sigmoid fit parameters for given single cell data types.
% Input: 
%   data - matrix of shape [len(cellIDs),4], containing the sigmoid parameters of each selected cells
%   data_filename - the filename of the saved .xlsx data export
%   cell_IDs - list of selected cellIDs
%   data_type - one of the following possible data_types: 'maxWS', 'IWS', 'avgWS', 'area'
% Returns:
%   None

key_string=strcat("\",data_type);
filename=insertAfter(data_filename,key_string,'_params');

param_header=["cellID","amplitude","rate","offset","baseline"];
xlswrite(filename,[param_header;[cell_IDs,data]]);
end

