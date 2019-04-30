function [sphericity vol_cm sa_cm] = readPatient(path_vnt,file_vnt,path_dcm,file_dcm,plot_flag,video_flag)
% Function to take a .vnt file from 4DVis, generate plots (if indicated) of
% point cloud and mesh representations, then output sphericity as a nfx1
% vector
% plot: do we want a figure to pop up (0 for no, 1 for yes)
% video: do we want a video to be saved (0 for no, 1 for yes)

% input check
if video_flag==1 && plot_flag==0
    warning('ACheng:readPatient',...
        'Check input arguments. Video cannot be generated without the plot');
    plot_flag=1; %set it anyway
end

% Scale, from the dicom
metadata=readDicom3D(strcat(path_dcm,file_dcm),0);
Scale1D = max(metadata.widthspan,max(metadata.heightspan,metadata.depthspan));

% edit file extension
dirname = strcat(path_vnt,'output');
if ~exist(dirname, 'dir')
       mkdir(dirname);
end
filename = [path_vnt, file_vnt];
%file = file(1:end-4);

% first frame
[points, type, base, apex, lat, Z, T] = load_vent_mesh(strcat(path_vnt,file_vnt));
nf = size(points,1); % number of frames
sphericity = zeros(nf,1);
R = squeeze(points(1,:,:)); % first frame only
[x,y,z] = pol2cart(T, R, Z);
PC = [x(:),y(:),z(:)];
PC = unique(PC,'rows');
shp = alphaShape(PC(:,1),PC(:,2),PC(:,3),Inf);
if (plot_flag==1)
    imagename = strcat(path_vnt,'output/',file_vnt,'_image_frame_1');
    figure;
    subplot(1,2,1)
    plot3(PC(:,1),PC(:,2),PC(:,3),'k.');
    daspect([1 1 1])
    title('Point cloud representation')
    subplot(1,2,2)
    plot(shp);
    daspect([1 1 1])
    axis tight
    title('Mesh representation')
    saveas(gcf,imagename,'png')
    if (video_flag==1)
        videoname = strcat(path_vnt,'output/',file_vnt,'_video_frame_1');
        OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
        CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], videoname ,OptionZ)
    end
end
sa = surfaceArea(shp);
vol = volume(shp);
sphericity(1) = pi^(1/3) * (6*vol)^(2/3) / sa;
fprintf('Filename: %s, Frame: %d, Sphericity: %0.3f \n', file_vnt, 1, sphericity(1));

% Volume calculation
zlen = sum((apex(1,:)-base(1,:)).^2).^0.5;
scale = pi * zlen / 128 / 256  * Scale1D * Scale1D * Scale1D; % su3 to cm3
vol_cm(1) = vol * Scale1D^3;
sa_cm(1) = sa * Scale1D^2;
%fprintf('Volume (cm^3): %0.3f, Surface area (cm^2): %0.3f\n', vol_cm, sa_cm);

for t=2:nf
    [points, type, base, apex, lat, Z, T] = load_vent_mesh(file_vnt);
    R = squeeze(points(t,:,:)); % which frame
    [x,y,z] = pol2cart(T, R, Z);
    PC = [x(:),y(:),z(:)];
    PC = unique(PC,'rows');
    shp = alphaShape(PC(:,1),PC(:,2),PC(:,3),Inf);
    sa = surfaceArea(shp);
    vol = volume(shp);
    sphericity(t) = pi^(1/3) * (6*vol)^(2/3) / sa;
    fprintf('Filename: %s, Frame %d: Sphericity: %0.3f \n', file_vnt, t, sphericity(t));
    
    % Volume calculation
    zlen = sum((apex(t,:)-base(t,:)).^2).^0.5;
    vol_cm(t) = vol * Scale1D^3;
    sa_cm(t) = sa * Scale1D^2;
    %fprintf('Volume (cm^3): %0.3f, Surface area (cm^2): %0.3f\n', vol_cm, sa_cm);
    
    if (plot_flag==1)
        imagename = strcat(path_vnt,'output/',file_vnt,'_image_frame_',num2str(t));
        figure;clf
        subplot(1,2,1)
        plot3(x,y,z,'k.');
        daspect([1 1 1])
        title('Point cloud representation')
        subplot(1,2,2)
        plot(shp);
        daspect([1 1 1])
        axis tight
        title('Mesh representation')
        saveas(gcf,imagename,'png')
        if (video_flag==1)
            videoname = strcat(path_vnt,'output/',file_vnt,'_video_frame_',num2str(t));
            OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
            CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], videoname ,OptionZ)
        end
        
    end
   
end

totalvals = [sphericity vol_cm.' sa_cm.'];
csv_name = strcat(path_vnt,'output/',file_vnt,'_output_values.csv');
csvwrite(csv_name,totalvals);

edv = sphericity(find(vol_cm==max(vol_cm)));
fprintf('End diastolic volume sphericity: %0.3f\n', edv);

% figure;clf
% subplot(3,1,1)
% plot(1:nf,vol_cm,'LineWidth',2)
% yyaxis left
% ylabel('Volume (cm^3)')
% hold on
% plot(1:nf,sa_cm,'LineWidth',2)
% yyaxis right
% ylabel('Surface area (cm^2)')
% title('Volume, surface area')
% xlabel('Frame')
% 
% subplot(3,1,2)
% plot(1:nf,sphericity,'LineWidth',2)
% title('Sphericity')
% xlabel('Frame')

    function CaptureFigVid(ViewZ, FileName,OptionZ)
        % CaptureFigVid(ViewZ, FileName,OptionZ)
        % Captures a video of the 3D plot in the current axis as it rotates based
        % on ViewZ and saves it as 'FileName.mpg'. Option can be specified.
        %
        % ViewZ:     N-rows with 2 columns, each row are the view angles in
        %            degrees, First column is azimuth (pan), Second is elevation
        %            (tilt) values outside of 0-360 wrap without error,
        %            *If a duration is specified, angles are used as nodes and
        %            views are equally spaced between them (other interpolation
        %            could be implemented, if someone feels so ambitious).
        %            *If only an initial and final view is given, and no duration,
        %            then the default is 100 frames.
        % FileName:  Name of the file of the produced animation. Because I wrote
        %            the program, I get to pick my default of mpg-4, and the file
        %            extension .mpg will be appended, even if the filename includes
        %            another file extension. File is saved in the working
        %            directory.
        % (OptionZ): Optional input to specify parameters. The ones I use are given
        %            below. Feel free to add your own. Any or all fields can be
        %            used
        % OptionZ.FrameRate: Specify the frame rate of the final video (e.g. 30;)
        % OptionZ.Duration: Specify the length of video in seconds (overrides
        %    spacing of view angles) (e.g. 3.5;)
        % OptionZ.Periodic: Logical to indicate if the video should be periodic.
        %    Using this removed the final view so that when the video repeats the
        %    initial and final view are not the same. Avoids having to find the
        %    interval between view angles. (e.g. true;)
        %
        % % % % Example (shown in published results, video attached) % % % %
        % figure(171);clf;
        % surf(peaks,'EdgeColor','none','FaceColor','interp','FaceLighting','phong')
        % daspect([1,1,.3]);axis tight;
        % OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
        % CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10],'WellMadeVid',OptionZ)
        %
        % Known issues: MPEG-4 video option only available on Windows machines. See
        % fix where the VideoWriter is called.
        %
        % Getframe is used to capture image and current figure must be on monitor 1
        % if multiple displays are used. Does not work if no display is used.
        %
        % Active windows that overlay the figure are captured in the movie.  Set up
        % the current figure prior to calling the function. If you don't specify
        % properties, such as tick marks and aspect ratios, they will likely change
        % with the rotation for an undesirable effect.
        
        % Cheers, Dr. Alan Jennings, Research assistant professor,
        % Department of Aeronautics and Astronautics, Air Force Institute of Technology
        
        %% preliminaries
        
        % initialize optional argument
        if nargin<3;     OptionZ=struct([]); end
        
        % check orientation of ViewZ, should be two columns and >=2 rows
        if size(ViewZ,2)>size(ViewZ,1); ViewZ=ViewZ.'; end
        if size(ViewZ,2)>2
            warning('AJennings:VidWrite',...
                'Views should have n rows and only 2 columns. Deleting extraneous input.');
            ViewZ=ViewZ(:,1:2); %remove any extra columns
        end
        
        % Create video object
        daObj=VideoWriter(FileName,'MPEG-4'); %my preferred format
        % daObj=VideoWriter(FileName); %for default video format.
        % MPEG-4 CANNOT BE USED ON UNIX MACHINES
        % set values:
        % Frame rate
        if isfield(OptionZ,'FrameRate')
            daObj.FrameRate=OptionZ.FrameRate;
        end
        % Durration (if frame rate not set, based on default)
        if isfield(OptionZ,'Duration') %space out view angles
            temp_n=round(OptionZ.Duration*daObj.FrameRate); % number frames
            temp_p=(temp_n-1)/(size(ViewZ,1)-1); % length of each interval
            ViewZ_new=zeros(temp_n,2);
            % space view angles, if needed
            for inis=1:(size(ViewZ,1)-1)
                ViewZ_new(round(temp_p*(inis-1)+1):round(temp_p*inis+1),:)=...
                    [linspace(ViewZ(inis,1),ViewZ(inis+1,1),...
                    round(temp_p*inis)-round(temp_p*(inis-1))+1).',...
                    linspace(ViewZ(inis,2),ViewZ(inis+1,2),...
                    round(temp_p*inis)-round(temp_p*(inis-1))+1).'];
            end
            ViewZ=ViewZ_new;
        end
        % space view angles, if needed
        if length(ViewZ)==2 % only initial and final given
            ViewZ=[linspace(ViewZ(1,1),ViewZ(end,1)).',...
                linspace(ViewZ(1,2),ViewZ(end,2)).'];
        end
        % Periodicity
        if isfield(OptionZ,'Periodic')&&OptionZ.Periodic==true
            ViewZ=ViewZ(1:(end-1),:); %remove last sample
        end
        % open object, preparatory to making the video
        open(daObj);
        
        %% rotate the axis and capture the video
        for kathy=1:size(ViewZ,1)
            view(ViewZ(kathy,:)); drawnow;
            writeVideo(daObj,getframe(gcf)); %use figure, since axis changes size based on view
        end
        
        %% clean up
        close(daObj);
    end
end

