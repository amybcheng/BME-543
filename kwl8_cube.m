clear;
%% import data
info=readDicom3D('cube.dcm');
data=info.data(:,:,:,1);
sz=size(data);
sz_min=min(sz);

%% set up dimensions
my=info.heightspan/sz_min; % proportionality constant between number of elements and actual width
xprime=info.widthspan/my; % number of desired elements in x-direction
zprime=info.depthspan/my; % number of desired elements in z-direction

% prime: map each data dimension to number of desired elements
xprime=linspace(1,sz(1),xprime);
yprime=linspace(1,sz(2),sz_min);
zprime=linspace(1,sz(3),zprime);

%% loops
new_cube=zeros(length(xprime),length(yprime),length(zprime));
new_cube(1,1,1)=data(1,1,1); % pin corner of cube to original corner of data
new_sz=size(new_cube);

for xind=2:new_sz(1)
    slice0=data(:,:,:,1);
    for yind=2:new_sz(2)
        for zind=2:new_sz(3)
            coords=[xprime(xind),yprime(yind),zprime(zind)];
            dx=mod(coords(1),1); % calculate decimal place remaining
            dy=mod(coords(2),1);
            dz=mod(coords(3),1);

            Bp=0;
            P=param_mat(dx,dy,dz);
            I=ind_mat(coords);
            for ind0=1:8 % ind0: row of P, I matrix corresponding to one neighboring point
                Bp0=P(ind0,1)*double(slice0(I(ind0,1),I(ind0,2),I(ind0,3)));
                Bp=Bp+Bp0;
            end
            new_cube(xind,yind,zind)=Bp;
        end
    end
end

%% determine cube size
figure(1)
hold on
[X,Y,Z]=ind2sub(size(new_cube),find(new_cube));
plot3(X,Y,Z, '.');
xlim([0,150])
ylim([0,150])
zlim([0,150])
daspect([1,1,1])

cube_ind=[X Y Z];
[k,V]=boundary(cube_ind);
trisurf(k,X,Y,Z,'Facecolor','red','FaceAlpha',0.1);
xV=info.widthspan/new_sz(1);
yV=info.heightspan/new_sz(2);
zV=info.depthspan/new_sz(3);
V=V.*xV.*yV.*zV;
fprintf('The volume of the cube is %0.0f cubic units.\n',V);


%% functions
function I=ind_mat(coords)
    I=ceil(coords);
    I=repmat(I,[8 1]);
    sub=[1 1 1; 1 0 1; 0 0 1; 0 1 1; ...
        1 1 0; 1 0 0; 0 0 0; 0 1 0];
    I=I-sub;
end

function P=param_mat(dx,dy,dz)
    P0=[(1-dx) (1-dy) (1-dz); (1-dx) dy (1-dz);...
        dx dy (1-dz); dx (1-dy) (1-dz);...
        (1-dx) (1-dy) dz; (1-dx) dy dz; ...
        dx dy dz; dx (1-dy) dz];
    P=zeros(8,1);
    for i=1:length(P)
        P(i)=P0(i,1)*P0(i,2)*P0(i,3);
    end
end