clear all;
he_ims = loadFilesFromDir('Collection 1/HE/', 'bmp');
p6_ims = loadFilesFromDir('Collection 1/p63AMACR/', 'bmp');
subplot(1,2,1)
imshow(he_ims{1})
subplot(1,2,2)
imshow(p6_ims{1})

%%
[kp,d] = vl_sift(he_ims{1})