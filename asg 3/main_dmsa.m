%% Code for part 1 of shape model project 
clc
clear
close all

% Load the DMSA images and manual segmentation
load dmsa_images
load man_seg

% Extract x- and y-coordinates
Xmcoord=real(man_seg);
Ymcoord=imag(man_seg);

% Choose patient and look at image
pat_nbr = 1;

figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy
axis equal
hold on
drawshape_comp(man_seg,[1 length(man_seg) 1],'.-r')


%% Code for part 2 of shape model project 
clc
clear
close all

% Load the DMSA images
load dmsa_images

% Choose patient and look at image
pat_nbr = 2;

figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy

% Load the manual segmentations
% Columns 1-20: the right kidney of patient 1-20
% Columns 21-40: the mirrored left kidney of patient 1-20
% Each row is a landmark position
load models

% Extract x- and y-coordinates
Xcoord=real(models);
Ycoord=imag(models);

% Mirror the left kidney to get it in the right position in the image
figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy
hold on
drawshape_comp(models(:,pat_nbr),[1 14 1],'.-r')
drawshape_comp((size(dmsa_images,2)+1)-models(:,pat_nbr+20)',[1 14 1],'.-r')
axis equal

%%

im1 = dmsa_images(:,:,1);
im2 = dmsa_images(:,:,pat_nbr);

match_coords_y = [Xcoord(:,1) Ycoord(:,1)]';
match_coords_x = [Xcoord(:,pat_nbr) Ycoord(:,pat_nbr)]';

R = [];
t = [];
s = 1;

th = 4;
best_ins = [];
best_ins_idx = [];

best_error = 100000000000;


for i = 1:10000
    sel = randi(size(match_coords_x,2), [1 2]);
    
    mcy = match_coords_y(:,sel);
    mcx = match_coords_x(:,sel);
    ins = [mcy; mcx];
    ins_idx = sel;
    
    [Rs, ts, ss] = computeTransformations(mcx, mcy, 1);
    
    for j = 1:size(match_coords_y, 2)
        if isempty(find(ismember(sel, j) == 1)) && (norm(match_coords_y(:,j) - ts - ss*Rs*match_coords_x(:,j))^2 < th)
            ins = [ins [match_coords_y(:,j); match_coords_x(:,j)]];
            ins_idx = [ins_idx j];
        end
    end
    
    
    if size(ins,2) > size(best_ins_idx, 2)
        mcyi = ins(1:2,:);
        mcxi = ins(3:4,:);
        R = Rs;
        t = ts;
        s = ss;
        best_ins = ins;
        best_ins_idx = ins_idx;
    end
end

%%
T = [s*R, t; 0, 0, 1];

tform = affine2d(T');

im3 = imwarp(im2, tform, 'OutputView', imref2d(size(im1)));
figure; clf;
imagesc(imfuse(im1, im3, 'blend'));

%%
l1 = [real(models(:,1)) imag(models(:,1))]';
l2 = [real(models(:,pat_nbr)) imag(models(:,pat_nbr))]';

[R,t,s] = computeTransformations(l1, l2, 1);

% l2p = s*R*l2 + t;

% plot(l1(1,:), l1(2,:));
% hold on;
% plot(l2p(1,:), l2p(2,:));

l1c = l1(1,:) + sqrt(-1)*l1(2,:);
% l2c = l2p(1,:) + sqrt(-1)*l2p(2,:);
l2c = transformPoints(models(:,pat_nbr), R, t, s)

figure
imagesc(dmsa_images(:,:,1))
colormap(gray)
axis xy
hold on
drawshape_comp(models(:,1),[1 14 1],'.-r')
drawshape_comp(models(:,pat_nbr),[1 14 1],'.-g')
axis equal

figure
imagesc(dmsa_images(:,:,1))
colormap(gray)
axis xy
hold on
drawshape_comp(l1c,[1 14 1],'.-r')
drawshape_comp(l2c',[1 14 1],'.-g')
axis equal

%%
shape = models(:,1);
[R,t,s] = computeTransformations(shape, models(:,2));

transformPoints(models(:,2), R, t, s)

%%
first_shape = models(:,1);
figure
imagesc(dmsa_images(:,:,1))
colormap(gray)
axis xy
hold on
drawshape_comp(models(:,1),[1 14 1],'.-r')
means = zeros(14, 40);
shape = first_shape;
conv_iters = 0;

for j = 1:100
    means(:,1) = shape;
    for i = 2:size(models, 2)
        [R,t,s] = computeTransformations(shape, models(:,i));

        means(:,i) = transformPoints(models(:,i), R, t, s);
    end
    
    meanshape = mean(means, 2);
    
    [R,t,s] = computeTransformations(first_shape, meanshape);
    
    new_shape = transformPoints(meanshape, R, t, s);
    
    err = norm(new_shape-shape);
    
    shape = new_shape;
    
    if err < 1e-4
        conv_iters = conv_iters + 1;
        if conv_iters > 2
            break
        end
    else
        conv_iters = 0;
    end
end

%%

%means = mean(means, 2);
figure
imagesc(dmsa_images(:,:,1))
colormap(gray)
axis xy
hold on

for i = 1:39
    [R,t,s] = computeTransformations(shape, models(:,i+1));

    points = transformPoints(models(:,i+1), R, t, s);
    drawshape_comp(points,[1 14 1],'.-r')
end
drawshape_comp(shape,[1 14 1],'.-g')
axis equal

%%
meanshape = shape;

aligned_models = zeros(14,40);

for i = 1:40
   [R,t,s] = computeTransformations(models(:,1), models(:,i));
   aligned_models(:,i) = transformPoints(models(:,i), R, t, s);
end

diffs = aligned_models-meanshape;

S = zeros(2*14);

diffs = [real(diffs); imag(diffs)]; % (x1 x2... y1 y2)

for i = 1:size(diffs, 1)
    S = S + diffs(:,i)*diffs(:,i)';
end

S = S/40;

%% eigens
[P,D] = eig(S);

lam = flip(diag(D));
P = flip(P, 2);

Pc = complex(P(1:end/2,:), P(1+end/2:end,:));
figure
imagesc(dmsa_images(:,:,1))
colormap(gray)
axis xy
hold on
drawshape_comp(meanshape,[1 14 1],'.-g')

drawshape_comp(meanshape + Pc(:,1)*2*sqrt(lam(1)), [1 14 1], '.-r')

%%
E_tot = sum(lam);
E = 0;
thresh = 0.95;
num_eigens = -1;
for i = 1:length(lam)
    E = E + lam(i);
    if E/E_tot >= thresh
        num_eigens = i;
        break
    end
end

%%

figure

for j = 8:14
    subplot(3, 2, j-7)
    imagesc(dmsa_images(:,:,1))
    colormap(gray)
    axis xy
    hold on
    drawshape_comp(shape,[1 14 1],'.-g')
    
    k(1) = 2*sqrt(lam(j));
    k(2) = -2*sqrt(lam(j));
    k(3) = sqrt(lam(j));
    k(4) = -sqrt(lam(j));
    k(5) = 0;
    for i = 1:5
        drawshape_comp(shape + Pc(:,j)*k(i), [1 14 1], '.-r')
    end
end

%%

for i = 1:3
    pat_nbr = i
    figure
    imagesc(dmsa_images(:,:,i))
    Xmean = meanshape;
    colormap(gray)
    axis xy
    hold on
    
    Ps = complex(P(1:end/2,1:num_eigens),P(1+end/2:end,1:num_eigens));
    X = models(:,pat_nbr);
    b = Ps.'*(X-Xmean);
    Xp = Xmean + Ps*b;
    [R,t,s] = computeTransformations(Xmean, Xp);
    points = transformPoints(Xp, R, t, s);
    
    drawshape_comp(X,[1 14 1],'.-g')
    drawshape_comp(points, [1 14 1], '.-r')
end

%% segmentation

im = dmsa_images(:,:,1);
imagesc(im)
colormap(gray)

imt = im > 40;

bw = bwlabel(imt);

im1 = bw == 2;

props = regionprops(im1, 'Centroid', 'Orientation', 'Area');

ts = props.Centroid;
Rs = props.Orientation;
Ss = props.Area;

fit_lin = fit(real(meanshape),imag(meanshape),'poly1')
figure
imagesc(im)
hold on;
colormap(gray)
drawshape_comp(meanshape,[1 14 1],'.-g')
x = linspace(0, 100);
plot(fit_lin, real(meanshape), imag(meanshape));


