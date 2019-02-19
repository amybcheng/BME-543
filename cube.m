metadata=readDicom3D('cube.dcm',0);
img=metadata.data;
size(img);
frame = img(:,:,:,1); % take 1st frame in time

%% Found white cube's dimensions by using diff() function
% In x: [67,157] = 91
% In y: [53,123] = 71
% In z: [52,156] = 105

%% Black dimensions are
% In x: 224
% In y: 176
% In z: 208

Nx = 224;
Ny = 176;
Nz = 208;

Nxp = 214;
Nyp = 215;
Nzp = 173;


%% Correct for sampling
[x_size, y_size, z_size] = size(frame);

out = zeros(Nxp,Nyp,Nzp);
for i=1:214
    for j=1:215
        for k=1:173
            x = 1+(i-1)*(Nx-1)/(Nxp-1);
            y = 1+(j-1)*(Ny-1)/(Nyp-1);
            z = 1+(k-1)*(Nz-1)/(Nzp-1);
            
            [A,B,C,D,E,F,G,H] = interpolation_3D(x,y,z);
            
%             for d=1:3
%                 if E[d] < 1
%                     E[d] = 1;
%                 end
%                 if D[d] > size(frame)[d]
%                     D[d] = size(frame)[d];
%                 end
%             end
            
            % X max
            F(1)=min(x_size,F(1));
            B(1)=min(x_size,B(1));
            D(1)=min(x_size,D(1));
            H(1)=min(x_size,H(1));
            
            % Y max
            C(2)=min(y_size,C(2));
            D(2)=min(y_size,D(2));
            G(2)=min(y_size,G(2));
            H(2)=min(y_size,H(2));
            
            % Z max
            A(3)=min(z_size,A(3));
            B(3)=min(z_size,B(3));
            C(3)=min(z_size,C(3));
            D(3)=min(z_size,D(3));
            
            % X min
            A(1)=max(1,A(1));
            E(1)=max(1,E(1));
            C(1)=max(1,C(1));
            G(1)=max(1,G(1));
            
            % Y min
            A(2)=max(1,A(2));
            E(2)=max(1,E(2));
            B(2)=max(1,B(2));
            F(2)=max(1,F(2));
            
            % Z min
            E(3)=max(1,E(3));
            F(3)=max(1,F(3));
            G(3)=max(1,G(3));
            H(3)=max(1,H(3));
            
            val_A = img(A(1),A(2),A(3))*A(4);
            val_B = img(B(1),B(2),B(3))*B(4);
            val_C = img(C(1),C(2),C(3))*C(4);
            val_D = img(D(1),D(2),D(3))*D(4);
            val_E = img(E(1),E(2),E(3))*E(4);
            val_F = img(F(1),F(2),F(3))*F(4);
            val_G = img(G(1),G(2),G(3))*G(4);
            val_H = img(H(1),H(2),H(3))*H(4);
            
            final = (val_A + val_B + val_C + val_D + val_E + val_F + val_G + val_H);
            
            out(i,j,k) = final;
            %interpolation_3D(x,y,z,?);
            %out(i,j,k) = img(round(x),round(y),round(z)); % change to my interpolation function later
        end
    end
end

%% Plot

figure(1)
subplot(1,2,1)
imshow(frame(:,:,floor(end/2)));
title('Original Image')
axis image
subplot(1,2,2)
imshow(out(:,:,floor(end/2)));
imshow(squeeze(out(:,floor(end/2),:)));
title('New Image')
axis image

