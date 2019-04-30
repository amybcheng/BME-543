%% making figures
clear 
clc
close all
[file, path, indx] = uigetfile('*.csv','MultiSelect','off');
matrix = csvread(strcat(path,file));
sphericity=matrix(:,1);
vol=matrix(:,2);
sa=matrix(:,3);

frame=1:length(sphericity);

figure;clf
plot(frame,vol,'LineWidth',2,'Color','k')
ylim([50 170])
yyaxis left
ylabel('Volume (cm^3)')
hold on
yyaxis right
plot(frame,sphericity,'LineWidth',2)
ylim([0.8 1])
ylabel('Sphericity')
title('Volume and sphericity per frame')
xlabel('Frame')

% %% volume plotting 4DViz
% [file, path, indx] = uigetfile('*.csv','MultiSelect','off');
% matrix = csvread(strcat(path,file));
% %classvols=matrix(1,:);
% %classstd=matrix(2,:);

