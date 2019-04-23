clear
close all
clc

[file, path, indx] = uigetfile('*.vnt','MultiSelect','on');
numFiles = numel(file);

if ischar(file(1))
    numFiles = 1;
end

if numFiles==1
    readPatient(path,file,1,1)
else
    for i=1:numFiles
        readPatient(path,file{i},1,1); % last 2 arguments are image and video
    end
end