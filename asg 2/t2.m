clear all;
he_ims = loadFilesFromDir('Collection 2/HE/', 'jpg');
p6_ims = loadTifsFromDir('Collection 2/TRF/', 'tif');

he_ims{1} = imread('cat.png', 'PNG');
p6_ims{1} = imread('cat_cropped.png', 'PNG');

%%
fprintf('%5s %5s %5s\n','R', 't', 's')
for i = 1:length(he_ims)
    tform = alignImagesSim(he_ims{i}, p6_ims{i});
    
    imwarped = imwarp(p6_ims{i}, tform, 'OutputView', imref2d(size(he_ims{i})));
    imf = imfuse(he_ims{i}, imwarped, 'blend');
    
  	imwrite(imf, ['./overlap_2/' num2str(i) '_test.png']);
    
    %imf = imfuse(he_ims{i}, p6_ims{i}, 'blend');
    
  	%imwrite(imf, ['./overlap_2/' num2str(i) '_unwarped.png']);
end
%%
[im_he, map1] = imread('cat.png', 'PNG');
[im_p6, map2] = imread('cat_cropped.png', 'PNG');

im_he = ind2rgb(im_he, map1);
im_p6 = ind2rgb(im_p6, map2);
ima = single(rgb2gray(im_he));
imb = single(rgb2gray(im_p6));
 
subplot(2,1,1)
imshow(im_he)
subplot(2,1,2)
imshow(im_p6, [0 255])


%%
[fa,da] = vl_sift(ima);
[fb,db] = vl_sift(imb);

[matches, scores] = vl_ubcmatch(da, db);

%%

imshow([ima imresize(imb, [size(ima, 1) size(ima, 2)])], [0 255]);
hold on;

perm = randperm(size(fa,2));
sel = perm(1:50);

offset = size(ima, 2);
dbo = [db(1,:) + offset; db(2:end,:)];
fbo = [fb(1,:) + offset; fb(2:end,:)];

h3a = vl_plotsiftdescriptor(da(:,matches(1,:)),fa(:,matches(1,:)));
set(h3a,'color','g');


h3b = vl_plotsiftdescriptor(dbo(:,matches(2,:)),fbo(:,matches(2,:)));
set(h3b,'color','r');

match_coords_a = fa(1:2, matches(1,:));
match_coords_b = fbo(1:2, matches(2,:));

line([match_coords_a(1,:); match_coords_b(1,:)], [match_coords_a(2,:); match_coords_b(2,:)], 'Color','b')

%%
match_coords_y = fa(1:2, matches(1,:));
match_coords_x = fb(1:2, matches(2,:));

R = [];
t = [];
s = 1;

th = 200;
best_ins = [];
best_ins_idx = [];

best_error = 100000000000;

% subplot(1,2,1);
% imshow(ima ./255);
% hold on;
% subplot(1,2,2);
% imshow(imb ./255);
% hold on;


for i = 1:10000
    sel = randi(size(matches,2), [1 2]);
    
    mcy = match_coords_y(:,sel);
    mcx = match_coords_x(:,sel);
    ins = [mcy; mcx];
    ins_idx = sel;
%     subplot(1,2,1);
%     plot(mca(1,:), mca(2,:), 'r+');
%     subplot(1,2,2);
%     plot(mcb(1,:), mcb(2,:), 'r+');
%     break
    
    [Rs, ts, ss] = computeTransformations(mcx, mcy, 1);
    
    for j = 1:size(match_coords_y, 2)
        if isempty(find(ismember(sel, j) == 1)) && (norm(match_coords_y(:,j) - ts - ss*Rs*match_coords_x(:,j))^2 < th)
            ins = [ins [match_coords_y(:,j); match_coords_x(:,j)]];
            ins_idx = [ins_idx j];
        end
    end
    
    
    if size(ins,2) > 4 && size(ins,2) > size(best_ins_idx, 2)
        mcyi = ins(1:2,:);
        mcxi = ins(3:4,:);
        R = Rs;
        t = ts;
        s = ss;
        best_ins = ins;
        best_ins_idx = ins_idx;
%         [Rs, ts, ss] = computeTransformations(mcxi, mcyi, 1);
%         err = 0;
%         
%         for j = 1:size(mcyi, 2)
%             err = err + norm(mcyi(:,j) - ts - ss*Rs*mcxi(:,j))^2;
%         end
%         
%         if err < best_error
%             err
%             best_error
%             best_ins = ins;
%             best_ins_idx = ins_idx;
% %             imshow(im_he)
% %             hold on;
% %             h3a = vl_plotsiftdescriptor(da(:,matches(1,best_ins_idx)),fa(:,matches(1,best_ins_idx)));
% %             set(h3a,'color','g');
% %             %savefas(gcf, ['./ins_imgs/' num2str(i) '.png']);
% %             hold off;
% %             pause
%             
%             best_error = err;
%             R = Rs;
%             t = ts;
%             s = ss;
%         end
        
    end
end



%%
%s = 1;
T = [s*R, t; 0, 0, 1];

tform = affine2d(T');

p6out = imwarp(im_p6, tform, 'OutputView', imref2d(size(im_he)));
figure; clf;
imshow(imfuse(im_he, p6out, 'blend'));

figure
subplot(2,2,1)
imagesc(ima);
subplot(2,2,2);
imagesc(imb);
subplot(2,2,3)
imagesc(ima);
subplot(2,2,4);
imagesc(p6out);

%%
offset = size(ima, 2);
dbo = [db(1,:) + offset; db(2:end,:)];
fbo = [fb(1,:) + offset; fb(2:end,:)];

imshow([ima ./255 imresize(imb, [size(ima, 1) size(ima, 2)])./255]);
hold on;
bi = best_ins_idx;
h3a = vl_plotsiftdescriptor(da(:,matches(1,bi)),fa(:,matches(1,bi)));
set(h3a,'color','g');


h3b = vl_plotsiftdescriptor(dbo(:,matches(2,bi)),fbo(:,matches(2,bi)));
set(h3b,'color','r');

match_coords_a = fa(1:2, matches(1,bi));
match_coords_b = fbo(1:2, matches(2,bi));

line([match_coords_a(1,:); match_coords_b(1,:)], [match_coords_a(2,:); match_coords_b(2,:)], 'Color','b')