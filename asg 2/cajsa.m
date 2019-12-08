clear all;
he_ims = loadFilesFromDir('Collection 1/HE/', 'bmp');
p6_ims = loadFilesFromDir('Collection 1/p63AMACR/', 'bmp');

bild1 = he_ims{1};
bild2 = p6_ims{1};
%%
figure
imshow(imfuse(bild2, bild1, 'blend'));
%%
bild1_gray = rgb2gray(bild1);
bild2_gray = rgb2gray(bild2);

bild1_single = single(bild1_gray);
bild2_single = single(bild2_gray);

%%
[F1, D1] = vl_sift(bild1_single);
[F2, D2] = vl_sift(bild2_single);
%%
[matches, scores]= vl_ubcmatch(D1,D2);
%% RANSAC
inliers = [];
threshold = 100;

for i = 1:50
    points_index = randi([1 length(matches)],1,2);
    
    bild1_coord = [F1(1:2,matches(1,points_index(1))) F1(1:2,matches(1,points_index(2)))];
    bild2_coord = [F2(1:2,matches(2,points_index(1))) F2(1:2,matches(2,points_index(2)))];
    
    %[that2, Rhat2, shat]= procrustes(bild1_coord, bild2_coord);
    mean1 = mean(bild1_coord,2);
    mean2 = mean(bild2_coord,2);
    
    tilde11 = double(bild1_coord(:,1))-mean1;
    tilde12 = double(bild1_coord(:,2))-mean1;
    tilde21 = double(bild2_coord(:,1))-mean2;
    tilde22 = double(bild2_coord(:,2))-mean2;
    
    H = tilde11*tilde21' + tilde12*tilde22';
    [U,D,V] = svd(H);
    
    Rhat = U*diag([1 det(U*V)])*V';
    that = mean2 - Rhat*mean1;
    
    y = that + Rhat*F1(1:2,matches(1,:));
   
    dist = sqrt((y(1,:)-F2(1,matches(2,:))).^2 + (y(2,:)-F2(2,matches(2,:))).^2);
    inliers_index = find(dist < threshold);
    if length(inliers_index) > length(inliers)
        inliers = inliers_index;
    end
end 
%%
H = 0;
bild1_coord_r = F1(1:2,matches(1,inliers(:)));
bild2_coord_r = F2(1:2,matches(2,inliers(:)));
    
mean1 = mean(bild1_coord_r,2);
mean2 = mean(bild2_coord_r,2);
   
for i = 1:length(inliers)
    H = H + (double(bild1_coord_r(:,i))-mean1)*(double(bild2_coord_r(:,i))-mean2)';
end
[U,D,V] = svd(H);
    
Rhat = U*diag([1 det(U*V)])*V';
that = mean2 - Rhat*mean1;
 
%%
T = [-Rhat, that ;0, 0, 1];
tform = affine2d(T');
I1_warp = imwarp(bild1, tform, 'OutputView', imref2d(size(bild2)));
figure; 
imshow(imfuse(bild2, I1_warp, 'blend'));