function [R,t,s] = alignKidney(im1,im2)

match_coords_y = [real(im1) imag(im1)]';
match_coords_x = [real(im2) imag(im2)]';

R = [];
t = [];
s = 1;

th = 10;
best_ins = [];
best_ins_idx = [];


for i = 1:300
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
end

