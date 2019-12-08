function [tform] = alignImagesSim(ima,imb)
ima = single(rgb2gray(ima));
imb = single(imb);

[fa,da] = vl_sift(ima);
[fb,db] = vl_sift(imb);

[matches, scores] = vl_ubcmatch(da, db);

match_coords_y = fa(1:2, matches(1,:));
match_coords_x = fb(1:2, matches(2,:));

R = [];
t = [];
s = 1;

th = 300;
best_ins = [];
best_ins_idx = [];

best_error = 100000000000;


for i = 1:10000
    sel = randi(size(matches,2), [1 2]);
    
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

fprintf('%3.2f %4.2f %4.2f\n', round(rad2deg(acos(R(1,1))), 1), round(norm(t),2), round(s,2))
T = [s*R, t; 0, 0, 1];

tform = affine2d(T');
end

