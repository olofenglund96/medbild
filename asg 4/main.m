mr_heart_info = mydicominfo('images/MR-heart-single.dcm');
%%
ct_thorax_info = mydicominfo('images/CT-thorax-single.dcm');

%%
[mr_heart_info, mr_heart_im] = mydicomread('images/MR-heart-single.dcm');

figure
imagesc(mr_heart_im)

%%
[ct_thorax_info, ct_thorax_im] = mydicomread('images/CT-thorax-single.dcm');

figure
imagesc(ct_thorax_im)
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

im_3d_trans = im_3d;
im_3d_sag = permute(im_3d, [1 3 2]);
im_3d_cor = permute(im_3d, [3 1 2]);
%%
im = im_3d_cor;
while 1
    for i = 1:size(im, 3)
        imagesc(im(:,:,i));
        title(['Image ' num2str(i) ' of ' num2str(size(im, 3))])
        colorbar
        colormap('gray')
        axis equal
        pause(0.1)
    end
end
