clear
close all
clc

[vntfile, path_vnt, indx_vnt] = uigetfile('*.vnt','MultiSelect','on');
numFiles = numel(vntfile);

[dcmfile, path_dcm, indx_dcm] = uigetfile('*.dcm','MultiSelect','on');

% only one patient at a time aka 1 dcm at a time

image_flag = 0;
video_flag = 0;

if ischar(vntfile(1))
    numFiles = 1;
end

if numFiles==1
    readPatient(path_vnt,vntfile,path_dcm,dcmfile,image_flag,video_flag);
else
    for i=1:numFiles
        readPatient(path_vnt,vntfile{i},path_dcm,dcmfile{i},image_flag,video_flag); % last 2 arguments are image and video
    end
end