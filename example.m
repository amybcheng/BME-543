%% CleanUP
close all
clear all
clc

%% Load Mesh
[points, type, base, apex, lat, Z, T] = load_vent_mesh('');

%% Plot
% use only the first frame
R = squeeze(points(1,:,:));

% convert to cartesian coords
[x,y,z] = pol2cart(T, R, Z);

% plot black markers on each mesh node
figure(1)
plot3(x,y,z,'k.');
zlen = sum((apex(1,:)-base(1,:)).^2).^0.5;

%% Make a mesh

DT = delaunayTriangulation(x(:),y(:),z(:));
[tri XA] = freeBoundary(DT);

figure(2)
trisurf(tri,XA(:,1),XA(:,2),XA(:,3), 'FaceColor', 'cyan', 'faceAlpha', 0.8);

total = 0;

for i=1:size(tri,1)
    length_A = abs(tri(i,1)-tri(i,2));
    length_B = abs(tri(i,1)-tri(i,3));
    length_C = abs(tri(i,2)-tri(i,3));
    area = 0.5*length_A*length_B*length_C;
    total = total + area;
end

%% I have a relative surface area -> convert to cm^2

% In raster.cpp: conversion factor for screen units^3 to cm^3
% scale = M_PI * z / RASTER_THETA / RASTER_Z * Scale * Scale * Scale;
% cm^3 = screen^3 * scale
% scale = (cm/screen)^3
% scale^2/3 = (cm/screen)^3*2/3
% cm^2 = screen^2 * scale^(2/3)
% RASTER_THETA = 256, RASTER_Z = 128, M_PI = pi, Scale = 
% z is the Euclidean 3D distance between the apex and base
% What is Scale? Line 17 Scale = scale?

% so scale^(2/3) = (M_PI * z / RASTER_THETA / RASTER_Z)^2

scale = pi * norm(apex-base) / 256 /128;
scale = scale*scale;
total_sqcm = total * scale;

volume = 120.82;

sphericity = pi^(1/3) * (6*volume)^(2/3) / total_sqcm;