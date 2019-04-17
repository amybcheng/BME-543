function x = ReadDicom3D(filename,MaxVolumes)

%function x = ReadDicom3D(filename,MaxVolumes)
%
% Inputs:
%   filename:   XYZ Dicom File Name (string) Exported from Sonos 7500 D.0
%   MaxVolumes: Limits the # of volumes to be read
%               Default: 0 (read all volumes)
%
% Outputs:
%   x           T3DArray Struct
%               Variable Names identical to C++ Class: T3DArray
%
%   By Karl Thiele (11/1/02)
% 
% 3D DICOM for Dummies, Disclaimers and Waivers
% 
% 1. Dummies refer to the R&D Staff at Philips Medical Systems.
% 2. This Matlab m-file is provided for your convenience in reading the 3D DICOM files.
% 3. The accuracy of this Matlab m-file, or the accuracy of the information contained in the 
%    data files is NOT guaranteed.
% 4. No technical support will be provided.
% 5. IN NO WAY should any information derived from the 3D files be used for diagnostic purposes.
% 6. NOT FOR DIAGNOSTIC USE
% 7. The contents of this Matlab m-file has not been verified for accuracy.
% 8. For Research Only
% 9. The contents of this Matlab m-file should not be communicated to other parties 
%    without the prior written consent of Philips Medical Systems
% 
% Any use of this Matlab m-file implies that you agree to the 
% aforementioned Disclaimers and Waivers.


% Output Disclaimer
disp('*************************************');
disp('*                                   *');
disp('*     NOT FOR DIAGNOSTIC USE        *');
disp('*                                   *');
disp('*************************************');

% set default/legacy behavior
if nargin<2, MaxVolumes=0; end;

% Get Header info
fid=fopen(filename,'r','l');    % Note small L "l" for Little Endian
if(~fid) error('could not open input file'); end;

% Waste first 128 Bytes
WasteBytes  = fread(fid,128,'char');

% Waste Dicom Label
DICM    = char(fread(fid,4,'char'));

% Initialize Dicom Tags for "while" loop
TagA = 0;
TagB = 0;

% Clearly Specify the Tags used at the beginning of the data
% Note that the loop will terminate when these Tags Occur!
Data_TagA    = hex2dec('7fe0');
Data_TagB    = hex2dec('0010');

LoopCounter = 0;

while ((TagA~=Data_TagA) | (TagB~=Data_TagB)) & (LoopCounter<200)

    LoopCounter = LoopCounter + 1;
    
    TagA    = fread(fid,1,'ushort');
    TagB    = fread(fid,1,'ushort');
    CODE    = char(fread(fid,2,'char'))';
    N       = fread(fid,1,'ushort');
    
%    display([num2str(LoopCounter) ' ' num2str(TagA) ' ' num2str(TagB) ' ' CODE ' ' num2str(N)]);
    
    switch TagA
        
    case hex2dec('0018')
        if TagB==hex2dec('602c')
            DeltaX  = fread(fid,1,'double');
        elseif TagB==hex2dec('602e')
            DeltaY  = fread(fid,1,'double');
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    case hex2dec('0028')
        if TagB==hex2dec('0008')
            tmpstr      = char(fread(fid,N,'char')');
            x.NumVolumes= sscanf(tmpstr,'%d');
        elseif TagB==hex2dec('0010')
            x.height  = fread(fid,1,'ushort');  % # of rows
        elseif TagB==hex2dec('0011')
            x.width  = fread(fid,1,'ushort');   % # of columns
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    case hex2dec('3001')
        if TagB==hex2dec('1001')
           x.depth  = fread(fid,1,'uint');  % this is 4 bytes, vs 2 bytes
           % for rows & cols
        elseif TagB==hex2dec('1003')
            DeltaZ  = fread(fid,1,'double');
        else
            WasteBytes = fread(fid,N,'char');
        end
        
    otherwise
        WasteBytes  = fread(fid,N,'char');
        
    end
    
    if (CODE == 'OB') WasteBytes = fread(fid,6,'char'); end;
    
end


if (LoopCounter>=200)
    fclose(fid);
    error('Sorry ... somehow I became mis-aligned on the tags');
end

% Ready to Read Data: Get Volume Loop Size
N   = fread(fid,1,'uint');

% Limit the # of Volumes, and Volume Loop Size
if MaxVolumes>0,
    x.NumVolumes = MaxVolumes;
    N = x.width*x.height*x.depth*x.NumVolumes;
end;

% Finally read volume data:
x.data  = fread(fid,N,'*uint8');

% Close file
fclose(fid);

% Now Calculate the T3DArray Header Information
x.filetype		= 'Hello';
x.N				= N;
x.N_padded	    = x.N;				
x.width_padded	= x.width;
x.height_padded	= x.height;
x.depth_padded	= x.depth;
x.m_Voxelsize 	= 1;

x.widthspan		= x.width * DeltaX;
x.heightspan	= x.height * DeltaY;
x.depthspan		= x.depth * DeltaZ;

x.widthstart	= -x.widthspan/2;
x.heightstart	= -x.heightspan/2;
x.depthstart	= -x.depthspan/2;

x.pdata			= 1;  % indicates that data exists

% Now we need to reshape the matrix
x.data=reshape(x.data,x.width_padded,x.height_padded,x.depth_padded,x.NumVolumes);

return