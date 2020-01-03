mr_heart_info = mydicominfo('images/MR-heart-single.dcm');
%%
ct_thorax_info = mydicominfo('images   /CT-thorax-single.dcm');

%%
[mr_heart_info, mr_heart_im] = mydicomread('images/MR-heart-single.dcm');

figure
imagesc(mr_heart_im)
title('CT of heart');
colorbar
axis image
colormap gray

%%
[ct_thorax_info, ct_thorax_im] = mydicomread('images/CT-thorax-single.dcm');

figure
imagesc(ct_thorax_im)
title('CT of thorax');
colorbar
axis image
colormap gray


%%
[ct_thorax_info, ct_thorax_im] = mydicomread('images/CT-thorax-single.dcm');

im = double(imgaussfilt(ct_thorax_im, 4));
im = (im - min(im, [], 'all'))./(max(im, [], 'all')-min(im, [], 'all'));
im = im > 0.6;
el = strel('disk', 4);
im = imopen(im, strel);
figure
imagesc(im)
%%
[test_inf, test_im] = mydicomread('C:\Users\olofe\Documents\MATLAB\MedBild\asg 4\images\MR-thorax-transversal\OUTIM0080.dcm');

figure
imagesc(test_im)
%%
test_im = dicomread('C:\Users\olofe\Documents\MATLAB\MedBild\asg 4\images\MR-thorax-transversal\OUTIM0080.dcm');
test_info = dicominfo('C:\Users\olofe\Documents\MATLAB\MedBild\asg 4\images\MR-thorax-transversal\OUTIM0080.dcm');

figure
imagesc(test_im)
%%
test_im = dicomread('images/MR-heart-single.dcm');

figure
imagesc(test_im)
%%
[im_3d, info_3d] = mydicomreadfolder;

%%
slice_thickness = str2double(info_3d.SliceThickness);
pix_spacing = split(info_3d.PixelSpacing, '\');
row_spacing = str2double(pix_spacing(1));
col_spacing = str2double(pix_spacing(2));
cols = info_3d.Columns;
rows = info_3d.Rows;
stack_height = size(im_3d, 3);

image_dims_mm = [col_spacing*cols, row_spacing*rows, slice_thickness*stack_height];

x_mm = [0,image_dims_mm(1)];
y_mm = [0,image_dims_mm(2)];
z_mm = [0,image_dims_mm(3)];

%%
im_3d_trans = im_3d;
im_3d_sag = permute(im_3d, [1 3 2]);
im_3d_cor = permute(im_3d, [2 3 1]);
%%
im = im_3d_trans;
while 1
    for i = 1:size(im, 3)
        imagesc(imrotate(im(:,:,i), 90));
        title(['\color{white}Image ' num2str(i) ' of ' num2str(size(im, 3))])
        colorbar
        colormap('gray')
        axis image
        set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
        set(gca,'color',[1 1 1]);
        set(gca,'ticklength',[0.05 0.05]);
        set(gcf,'color',[0 0 0]);
        pause(0.1)
    end
end

%%
mid_trans = im_3d_trans(:,:,round(end/2));
mid_sag = im_3d_sag(:,:,round(end/2));
mid_cor = im_3d_cor(:,:,round(end/2));

figure
imagesc(x_mm, y_mm, mid_trans);
title('\color{white}Transversal view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'color',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);
figure
imagesc(x_mm, z_mm, imrotate(mid_sag, -90));
title('\color{white}Sagital view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);
figure
imagesc(y_mm, z_mm, imrotate(mid_cor, 90));
title('\color{white}Coronal view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);

pause
close all

%%
