function [R,t,s] = computeTransformations(x,y,alg)
%COMPUTETRANSFORMATIONS Summary of this function goes here
%   Detailed explanation goes here
    xb = mean(x,2);
    yb = mean(y,2);
    
    xt = double(x) - xb;
    yt = double(y) - yb;
    
    H = zeros(2);
    
    for i = 1:size(x, 1)
        H = H + yt(:,i)*xt(:,i)';
    end
    
    [U,S,V] = svd(H);
    R = U*[1 0; 0 det(U*V)]*V';
    s = 1;
    
    if alg == 1
        st = 0;
        sd = 0;
        for i = 1:size(x,1)
            st = st + yt(:,i)'*R*xt(:,i);
            sd = sd + norm(xt(:,i))^2;
        end
        s = st/sd;
        
        %sp = sum(diag(yt'*R*xt))/sum(norm(xt)^2);
    end
    
    t = yb - s*R*xb;
end

