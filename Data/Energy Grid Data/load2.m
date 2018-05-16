%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Volumes/Backup/OneDrive/OneDrive - University of Edinburgh/Google Drive/Edinburgh/Year 4/BEng Project/Data/Energy Grid Data/gridwatch.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2018/02/14 15:03:03

%% Initialize variables.
filename = '/Volumes/Backup/OneDrive/OneDrive - University of Edinburgh/Google Drive/Edinburgh/Year 4/BEng Project/Data/Energy Grid Data/gridwatch.csv';
delimiter = ',';
startRow = 2;

%% Format for each line of text:
%   column1: double (%f)
%	column2: datetimes (%{yyyy-MM-dd HH:mm:ss}D)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: double (%f)
%	column18: double (%f)
%   column19: double (%f)
%	column20: double (%f)
%   column21: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%{yyyy-MM-dd HH:mm:ss}D%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
% id = dataArray{:, 1};
timestamp = dataArray{:, 2};
demand = dataArray{:, 3};
frequency = dataArray{:, 4};
% coal = dataArray{:, 5};
% nuclear = dataArray{:, 6};
% ccgt = dataArray{:, 7};
% wind = dataArray{:, 8};
% pumped = dataArray{:, 9};
% hydro = dataArray{:, 10};
% biomass = dataArray{:, 11};
% oil = dataArray{:, 12};
% solar = dataArray{:, 13};
% ocgt = dataArray{:, 14};
% french_ict = dataArray{:, 15};
% dutch_ict = dataArray{:, 16};
% irish_ict = dataArray{:, 17};
% ew_ict = dataArray{:, 18};
% other = dataArray{:, 19};
% north_south = dataArray{:, 20};
% scotland_england = dataArray{:, 21};

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% timestamp=datenum(timestamp);


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;