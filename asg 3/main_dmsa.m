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
pat_nbr = 10;




figure
imagesc(dmsa_images(:,:,pat_nbr))
colormap(gray)
axis xy
axis equal
hold on
drawshape_comp(man_seg,[1 length(man_seg) 1],'.-r')



tdist = 0;

for i = 1:length(Xmcoord)-1
    tdist = tdist + pdist([Xmcoord(i) Ymcoord(i); Xmcoord(i+1) Ymcoord(i+1)]);
end

tdist = tdist + pdist([Xmcoord(end) Ymcoord(end); Xmcoord(1) Ymcoord(1)]);

spacing = tdist/14;
rem = spacing;
pi = 2;
points = [Xmcoord(1) Ymcoord(1)];
for i = 1:length(Xmcoord)
   
    if i ~= length(Xmcoord)
        p1 = [Xmcoord(i) Ymcoord(i)];
        p2 = [Xmcoord(i+1) Ymcoord(i+1)];
    else     
        p1 = [Xmcoord(i) Ymcoord(i)];
        p2 = [Xmcoord(1) Ymcoord(1)];
    end
    
    cdist = pdist([p1; p2]);
    
    if rem > cdist
        rem = rem-cdist;
    else
        part = rem/cdist;
%         p = polyfit([p1(1) p2(1)], [p1(2) p2(2)], 1);
%         
%         angle = atan(p(1));
%         
%         xp = Xmcoord(i) + rem*cos(angle);
%         yp = polyval(p, xp);
%         
        v = (p2-p1)/norm(p2-p1);
        
        np = p1 + part*v;

        points = [points; np];
       
        rem = spacing - (cdist-rem);
    end
end

drawshape_comp(points,[1 14 1],'.-g')


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
plot(lam, 'o')

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

Pb = P(:,1:num_eigens);
lamb = lam(1:num_eigens);

%%

figure

for j = 1:6
    subplot(3, 2, j)
    %imagesc(dmsa_images(:,:,1))
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

im = dmsa_images(:,:,end-1);
imagesc(im)
colormap(gray)

imt = im > 40;
bw = bwlabel(imt);

im1 = bw == 2;

meanim = poly2mask(real(meanshape),imag(meanshape),128,128);
meanshapexy = [real(meanshape), imag(meanshape)];

props = regionprops(im1, 'Centroid', 'Orientation', 'Area');
meanprops = regionprops(meanim, 'Orientation', 'Area');

Rs = props.Orientation;
Ss = props.Area;

Rs_mean = meanprops.Orientation;
Ss_mean = meanprops.Area;

Rsdiff = abs(Rs-Rs_mean);
Ssdiff = Ss/Ss_mean;

R = [cosd(Rsdiff) -sind(Rsdiff); sind(Rsdiff) cosd(Rsdiff)];
trans_mean = Ssdiff*R*meanshapexy';

meanprops = regionprops(meanim, 'Centroid');
ts = props.Centroid;
ts_mean = mean(trans_mean, 2);

tsdiff = ts'-ts_mean;
trans_mean = trans_mean + tsdiff;

trans_mean = trans_mean';

%%
bounds = bwboundaries(im1);

points = fliplr(bounds{1});

best_points = [];

for i = 1:size(trans_mean,1)
    tpoint = trans_mean(i,:);
    le = 10000000;
    bp = [];
    for j = 1:size(points,1)
        cpoint = points(j,:);
        err = norm(cpoint-tpoint);
        
        if err < le
            bp = cpoint;
            le = err;
        end
    end
    
    best_points = [best_points; bp];
end

kid_points = best_points;
figure
imshow(im1)
hold on;
drawshape_comp(kid_points, [1 14 1],'.-b')
drawshape_comp(trans_mean, [1 14 1],'.-r')

[Rs, ts, ss] = computeTransformations(best_points, meanshapexy);
new_trans_mean = transformPoints(meanshapexy, Rs, ts, ss);

figure
imshow(im1)
hold on;
drawshape_comp(kid_points, [1 14 1],'.-b')
drawshape_comp(new_trans_mean, [1 14 1],'.-r')
trans_mean = [real(new_trans_mean) imag(new_trans_mean)];
%% alignment
new_trans_meanxy = [real(new_trans_mean) imag(new_trans_mean)];
bt = Pb'*(kid_points(:) - new_trans_meanxy(:));

prot = Pb*bt;

Pb_points = new_trans_meanxy + [prot(1:end/2) prot(1+end/2:end)];

[R,t,s] = computeTransformations(kid_points, Pb_points);

Pb_points_t = transformPoints(Pb_points, R, t, s);
Pbpxy = [real(Pb_points_t) imag(Pb_points_t)];

Pb_x = (R'*(Pbpxy' - tsdiff)/Ssdiff)';
t = 0.001;
ms_stacked = meanshapexy(:);
Pb_stacked = Pb_x(:);
for i = 1:100
    dX = ms_stacked - Pb_stacked;
    db = Pb'*dX(:);
    newb = bt+db;
    Pb_stacked = ms_stacked + Pb*(bt+db);
    
    if db < t
        break
    end
    bt = newb;
end

Pb_final = [Pb_stacked(1:end/2) Pb_stacked(1+end/2:end)];

[R,t,s] = computeTransformations(kid_points, Pb_final);

Pb_final_t = transformPoints(Pb_final, R, t, s);

%%
imagesc(im)
hold on;
colormap(gray)
%drawshape_comp(Pb_x, [1 14 1],'.-b')
drawshape_comp(Pb_final_t, [1 14 1],'.-g')
%drawshape_comp(meanshape,[1 14 1],'.-b')

%%
figure
%subplot(2, 1, 1)
imagesc(im1)

drawshape_comp(trans_mean,[1 14 1],'.-g')
drawshape_comp(kid_points,[1 14 1],'.-r')
drawshape_comp(Pb_points,[1 14 1],'.-b')
drawshape_comp(Pb_points_t, [1 14 1],'.-m')
%plot(points(:,1), points(:,2))
% for i = 1:size(trans_mean, 1)
%     line([trans_mean(:,1) best_points(:,1)], [trans_mean(:,2) best_points(:,2)])
% end

% subplot(2, 1, 2)
% imagesc(meanim)
% hold on;
% colormap(gray)
% plot(ts_mean(1), ts_mean(2), 'r+');