function [F, STR] = get_features(image, mask)
%keyboard;
F(1) = mean(image(find(mask)));
STR{1} = 'mean intensity';

F(2) = std(image(find(mask)));
STR{2} = 'std dev';

img = image(find(mask));
imb = img > F(1);
lbl = bwlabel(imb);
patches = max(lbl,[],'all');
F(3) = patches;
STR{3} = 'image patches';

imb = img > F(1);
bwa = bwarea(imb);
area_means = bwa/patches;
F(4) = area_means;
STR{4} = 'mean area of patches';

imb = img > F(1);
total_area = bwarea(imb);
F(5) = total_area;
STR{5} = 'total area of patches';

imb = img > F(1);
stats = regionprops(imb, 'Eccentricity');
mean_ecc = mean([stats.Eccentricity]);
F(6) = mean_ecc;
STR{6} = 'mean eccentricity of patches';

% Need to name all features.
assert(numel(F) == numel(STR));