function [points, type, base, apex, lat, Z, T] = load_vent_mesh(filename)

%LOAD_VENT_MESH - load *.vnt file and extract coordinates
%   [POINTS, TYPE, BASE, APEX, LAT, Z, T] = LOAD_VENT_MESH(FILENAME)
%   Opens the file FILENAME and returns:
%       POINTS: a [nf, nt, nz] array with the radial value of a ventricle
%       mesh node. (nf: number of frames, nt: number of theta samples, nz:
%       number of height samples)
%
%       TYPE: a [nf, nt, nz] array with the type of ventricle mesh node
%       (NONE=0, USER=1, INTERP1=2, INTERP2=4).(nf: number of frames, nt:
%       number of theta samples, nz: number of height samples)
%
%       BASE: a [nf, 3] array with the cartesian coordinates (x,y,z) of the
%       ventricle base point for every frame.(nf: number of frames)
%
%       APEX: a [nf, 3] array with the cartesian coordinates (x,y,z) of the
%       ventricle apex point for every frame.(nf: number of frames)
%
%       LAT: a [nf, 3] array with the cartesian coordinates (x,y,z) of the
%       ventricle lateral wall point for every frame.(nf: number of frames)
%       
%       Z,T: a [nt, nz] array with the height and angular coordinate values
%       in meshgrid form. These values are valid for all frames.
%
%   The FILENAME parameter determines the file to be open. In case this
%   parameter is an empty string, a loadfile window (See UIGETFILE) will
%   open for the user to select a file.
%
%   Example:
%       % load ventricular mesh
%       [points, type, base, apex, lat, Z, T] = load_vent_mesh('03.vnt');
%
%       % use only the first frame
%       R = squeeze(points(1,:,:));
%
%       % convert to cartesian coords
%       [x,y,z] = pol2cart(T, R, Z);
%
%       % plot black markers on each mesh node
%       plot3(x,y,z,'ok');
%
%
% Copyright: 
% 2019 Marcelo Lerendegui <marcelo@lerendegui.com>
%
% load_vent_mesh is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% any later version.
%
% load_vent_mesh is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with load_vent_mesh. If not, see <https://www.gnu.org/licenses/>.


if isempty(filename)
    [file, path, indx] = uigetfile('*.vnt');
    filename = [path, file];
end

if isequal(file, 0)
    error("No input file!")
    return
end

%% Constants

RASTER_Z = 128;
RASTER_THETA = 256;

%% Read Header
fid = fopen(filename, 'rb');

% Read and verify magic number marker
ventfile_number = fread(fid, 1, 'int');
if ventfile_number ~= hex2dec('1152FA57') 
    msgbox("Invalid file type!", "Error")
    fclose(fid);
    return;
end


% Read name of original ultrasound file
fname_len = fread(fid, 1, 'int');
fname = fread(fid, fname_len, 'char');

% Read number of volumes ("frames")
nVols = fread(fid,1,'int');

% Read number height and angular samples
RasterZ = fread(fid, 1, 'int');
RasterT = fread(fid, 1, 'int');

% Verify correct number of samples
if (RasterZ ~= RASTER_Z) || (RasterT ~= RASTER_THETA)
    msgbox("Incorrect number of samples dimesions.", "Error");
    fclose(fid);
    return;
end

% get the start of data offset
offset = ftell(fid);
vframesize = RasterZ * RasterT;
fclose(fid);

%% Memoory Map Data
m = memmapfile(filename, 'Offset', offset, ...
    'Format', { ...
        'single', [3], 'base'; ...
        'single', [3], 'apex'; ...
        'single', [3], 'lat'; ...
        'double', [2 vframesize], 'points' ...
    }, ...
    'Repeat', nVols);

%% Generate Output Data
points = zeros(nVols, RasterT, RasterZ, 'double');
type = zeros(nVols, RasterT, RasterZ, 'int32');
base = zeros(nVols,3);
apex = zeros(nVols,3);
lat = zeros(nVols,3);

for f = 0:nVols-1
    points(f+1,:,:) = reshape(m.Data(f+1).points(1,:), [RasterT, RasterZ]);
    
    typ_int32 = typecast(m.Data(f+1).points(2,:), 'uint32');
    type(f+1,:,:) = reshape(typ_int32(1:2:end), [RasterT, RasterZ]);
    
    base(f+1,:) = m.Data(f+1).base;
    apex(f+1,:) = m.Data(f+1).apex;
    lat(f+1,:) = m.Data(f+1).lat;
end

%% Create Point Coordinates

% The z coordinates are refered only to the first frame user input
zlen = sum((apex(1,:)-base(1,:)).^2).^0.5;

t = linspace(0, 2*pi, RasterT);
z = linspace(0, zlen, RasterZ);

[Z, T] = meshgrid(z, t);

