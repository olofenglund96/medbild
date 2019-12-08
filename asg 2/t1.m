clear all;
he_ims = loadFilesFromDir('Collection 1/HE/', 'bmp');
p6_ims = loadFilesFromDir('Collection 1/p63AMACR/', 'bmp');

%%
fprintf('%5s %5s\n','R', 't')
for i = 1:length(he_ims)

    tform = alignImages(he_ims{i}, p6_ims{i});
    
    imwarped = imwarp(p6_ims{i}, tform, 'OutputView', imref2d(size(he_ims{i})));
    imf = imfuse(he_ims{i}, imwarped, 'blend');
    
  	imwrite(imf, ['./overlap_1/' num2str(i) '_test.png']);
%     
%     imf = imfuse(he_ims{i}, p6_ims{i}, 'blend');
%     
%   	imwrite(imf, ['./overlap_1/' num2str(i) '_unwarped.png']);
end
%%
im_he = he_ims{8};
im_p6 = p6_ims{8};
ima = single(rgb2gray(im_he));
imb = single(rgb2gray(im_p6));
 
subplot(1,2,1)
imagesc(ima)
subplot(1,2,2)
imagesc(imb)


%%
[fa,da] = vl_sift(ima);
[fb,db] = vl_sift(imb);

[matches, scores] = vl_ubcmatch(da, db);

%%

imshow([ima ./255 imresize(imb, [size(ima, 1) size(ima, 2)])./255]);
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
%saveas(gcf, './overlap_1/sift.png')
line([match_coords_a(1,:); match_coords_b(1,:)], [match_coords_a(2,:); match_coords_b(2,:)], 'Color','b')
%saveas(gcf, './overlap_1/sift_match.png')
%%
match_coords_y = fa(1:2, matches(1,:));
match_coords_x = fb(1:2, matches(2,:));

R = [];
t = [];
s = 1;

th = 100;
best_ins = [];
best_ins_idx = [];

best_error = 100000000000;


for i = 1:10000
    sel = randi(size(matches,2), [1 2]);
    
    mcy = match_coords_y(:,sel);
    mcx = match_coords_x(:,sel);
    ins = [mcy; mcx];
    ins_idx = sel;
    
    [Rs, ts] = computeTransformations(mcx, mcy, 0);
    
    for j = 1:size(match_coords_y, 2)
        if isempty(find(ismember(sel, j) == 1)) && (norm(match_coords_y(:,j) - ts - Rs*match_coords_x(:,j))^2 < th)
            ins = [ins [match_coords_y(:,j); match_coords_x(:,j)]];
            ins_idx = [ins_idx j];
        end
    end
    
    
    if size(ins,2) > size(best_ins_idx, 2)
        mcyi = ins(1:2,:);
        mcxi = ins(3:4,:);
        R = Rs;
        t = ts;
        best_ins = ins;
        best_ins_idx = ins_idx;
    end
end

%%
s = 1;
T = [s*R, t; 0, 0, 1];

tform = affine2d(T');

p6out = imwarp(im_p6, tform, 'OutputView', imref2d(size(im_he)));
figure; clf;
imshow(imfuse(im_he, p6out, 'blend'));

figure
subplot(2,2,1)
imagesc(imb);
subplot(2,2,2);
imagesc(ima);
subplot(2,2,3)
imagesc(imb);
subplot(2,2,4);
imagesc(p6out);

%%

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