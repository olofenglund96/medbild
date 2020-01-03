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
im_3d_cor = im_3d;
im_3d_sag = permute(im_3d, [1 3 2]);
im_3d_trans = permute(im_3d, [2 3 1]);
%%
% im = im_3d_cor;
% while 1
%     for i = 1:size(im, 3)
%         imagesc(imrotate(im(:,:,i), 90));
%         title(['Image ' num2str(i) ' of ' num2str(size(im, 3))])
%         colorbar
%         colormap('gray')
%         axis equal
%         pause(0.1)
%     end
% end

%%
mid_trans = max(im_3d_trans, [], 3);
mid_sag = max(im_3d_sag, [], 3);
mid_cor = max(im_3d_cor, [], 3);

figure
imagesc(x_mm, y_mm, mid_cor);
title('\color{white}Coronal view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'color',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);
figure
imagesc(x_mm, z_mm, mid_trans');
title('\color{white}Transversal view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);
figure
imagesc(z_mm, y_mm, mid_sag);
title('\color{white}Sagital view')
c = colorbar
c.Color = [1 1 1];
colormap('gray')
axis image
set(gca,'xcolor',[1 1 1],'ycolor',[1 1 1]);
set(gca,'ticklength',[0.05 0.05]);
set(gcf,'color',[0 0 0]);

pause
close all