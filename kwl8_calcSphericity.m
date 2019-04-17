%% initialize workspace
close all
clearvars -except new_cube new_sz info
clc

%% create geometry
geometry = inputdlg("Input desired geometry, 'cube' or 'sphere.'", 'Input');
dims = [1 50];
geometry = geometry{1};
b0 = strcmp(geometry, 'sphere');
b1 = strcmp(geometry, 'cube');

if b0 == 1
    [x,y,z]= sphere(50);
elseif b1 == 1
    b2 = isempty(new_cube);
    if b2 == 0
        [x,y,z]=ind2sub(size(new_cube),find(new_cube));
        xV=info.widthspan/new_sz(1);
        yV=info.heightspan/new_sz(2);
        zV=info.depthspan/new_sz(3);
        
        x=x.*xV;
        y=y.*yV;
        z=z.*zV;
    else
        fprintf('Please run kwl8_cube.m first.\n')
    end
else
    fprintf("Input either 'sphere' or 'cube.'")
end

%% convert surf to point cloud
figure(1)
subplot(1,2,1)
plot3(x,y,z,'k.');
daspect([1 1 1])

%% convert mesh to point cloud
PC = [x(:),y(:),z(:)];
shp = alphaShape(PC(:,1),PC(:,2),PC(:,3),Inf);
sa = surfaceArea(shp);

figure(1)
subplot(1,2,2)
plot(shp)
daspect([1 1 1])
if b0 == 1
    xlim([-1 1])
    ylim([-1 1])
    zlim([-1 1])
end

vol = volume(shp);

sphericity = pi^(1/3) * (6*vol)^(2/3) / sa;

fprintf('SA: %0.3f \n', sa);
fprintf('Volume: %0.3f \n', vol);
fprintf('Sphericity: %0.3f \n', sphericity);
fprintf('\n')