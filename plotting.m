%% making figures
clear 
clc
close all
[file, path, indx] = uigetfile('*.csv','MultiSelect','off');
matrix = csvread(strcat(path,file));
sphericity=matrix(:,1);
vol=matrix(:,2);
sa=matrix(:,3);

pt_num=convertCharsToStrings(file(1:3));

%% for 005 due to missing value for frame 0
%vol(1)=[];
%sphericity(1)=[];

%% for all patients
frame=0:(length(sphericity)-1);

%% for 003_first_draft due to missing value for second to last frame
%vol(end-1)=[];
%sphericity(end-1)=[];
%frame(end-1)=[];

%%
figure; clf
fig = figure;
left_color = [0 0 0];
right_color = [0 0 1];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);

plot(frame,vol,'LineWidth',2,'Color','k')
xlim([(min(frame)-0.5) (max(frame)+0.5)])

% ylim([20 200]) % 002, 003
% ylim([180 360]) % 004, 005
ylim([60 240]) % 001, 006

yyaxis left
ylabel('Volume (cm$^{3}$)')
hold on
yyaxis right
plot(frame,sphericity,'LineWidth',2,'Color','b')
ylim([0.8 1])
ylabel('Sphericity','Color','b')
title('Volume and sphericity per frame (' + pt_num + ')')
xlabel('Frame')

% %% volume plotting 4DViz
% [file, path, indx] = uigetfile('*.csv','MultiSelect','off');
% matrix = csvread(strcat(path,file));
% %classvols=matrix(1,:);
% %classstd=matrix(2,:);

