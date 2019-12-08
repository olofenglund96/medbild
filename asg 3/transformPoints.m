function [pout] = transformPoints(shape, R, t, s)

l2 = [real(shape) imag(shape)]';

l2p = s*R*l2 + t;

l2c = complex(l2p(1,:), l2p(2,:));

pout = l2c.';
end

