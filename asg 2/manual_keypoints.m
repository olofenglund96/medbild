he_ims = loadFilesFromDir('Collection 1/HE/', 'bmp');
p6_ims = loadFilesFromDir('Collection 1/p63AMACR/', 'bmp');

%%
he_ims = loadFilesFromDir('Collection 2/HE/', 'jpg');
p6_ims = loadTifsFromDir('Collection 2/TRF/', 'tif');

%%

% [im_he, map1] = imread('cat.png', 'PNG');
% [im_p6, map2] = imread('cat.png', 'PNG');
% 
% im_he = ind2rgb(im_he, map1);
% im_p6 = ind2rgb(im_p6, map2);
% im1 = single(rgb2gray(im_he));
% im2 = single(rgb2gray(im_p6));
% 

kps_l = {};
kps_r = {};
for j = 1:length(he_ims)
    im1 = he_ims{j};
    im2 = p6_ims{j};
    %im2 = imresize(p6_ims{5}, [size(im1,1) size(im1,2)]);
    hold off;
    figure(1)
    imshow(im1);

    figure(2)
    imshow(im2, [0 255]);

    offset = size(im1, 2);
    height = size(im1, 1);

    left_xy = [];
    right_xy = [];
    i = 0;
    while true
        if i == 0
            figure(1)
            hold on;
            [x, y, button] = ginput(1)
            if button ~= 1
                break
            end

            plot(x, y, 'g+', 'MarkerSize', 30, 'LineWidth', 3);
            hold off;
            left_xy = [left_xy [x;y]];
            i = 1;
        else
            figure(2)
            hold on;
            [x, y, button] = ginput(1);

            if button ~= 1
                break
            end

            plot(x, y, 'r+', 'MarkerSize', 30, 'LineWidth', 3);
            hold off;
            right_xy = [right_xy [x;y]];
            i = 0;
        end
    %     if size(right_xy, 2) >= 2 && size(right_xy, 2) == size(left_xy, 2)
    %         figure(2)
    %         [R, t] = computeTransformations(right_xy, left_xy, 0);
    %         T = [R, t; 0, 0, 1];
    % 
    %         tform = affine2d(T');
    % 
    %         im = imwarp(im2, tform, 'OutputView', imref2d(size(im1)));
    %         imshow(imfuse(im1, im, 'blend'));
    %     end
    end
    close all
    kps_l{j} = left_xy;
    kps_r{j} = right_xy;
end

save('manual_kps', 'kps_l', 'kps_r')

%%
load('manual_kps')
for i = 1:length(kps_l)
    im1 = he_ims{i};
    im2 = p6_ims{i};

    [R, t, s] = computeTransformations(kps_r{i}, kps_l{i}, 1);

    %s = 1;
    T = [s*R, t; 0, 0, 1];

    tform = affine2d(T');

    im = imwarp(im2, tform, 'OutputView', imref2d(size(im1)));
    figure; clf;
    imshow(imfuse(im1, im, 'blend'));
end