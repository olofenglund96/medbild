function [pout] = transformPoints(shape, R, t, s)

l2 = [real(shape) imag(shape)]';


l2p = s*R*l2 + t;

if any(l2p(2,:) < 0)
    l2
    l2p(2,:)
    l2(2,:)
    R
    s
    t
    pause
end

l2c = l2p(1,:) + sqrt(-1)*l2p(2,:);

pout = l2c';
end

