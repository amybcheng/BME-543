metadata=readDicom3D('cube.dcm',0);
x=metadata.data;
size(x)
frame = x(:,:,:,1);

out = zeros(176,176,176);
for i=1:176
    for j=1:176
        for k=1:176
            xprime = 1+(i-1)*(224-1)/(176-1);
            zprime = 1+(k-1)*(208-1)/(176-1);
            out(i,j,k) = x(round(xprime),j,round(zprime));
        end
    end
end

figure(1)
subplot(1,2,1)
imshow(frame(:,:,end/2));
title('Original Image')
axis image
subplot(1,2,2)
imshow(out(:,:,end/2));
title('New Image')
axis image

%%
[A B C D] = interpolation(0.5,0.5,0.5,1)
