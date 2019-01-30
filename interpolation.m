function [A,B,C,D] = interpolation(x,y,z,intensity)
% For now, 2D and origin is top left (A)
A = [floor(x),floor(y)];
B = [ceil(x),floor(y)];
C = [floor(x),ceil(y)];
D = [ceil(x),ceil(y)];

alpha = x - A(1);
beta = y - B(2);

A(3) = intensity * (1-alpha) * (1-beta);
B(3) = intensity * (alpha) * (1-beta);
C(3) = intensity * (1-alpha) * (beta);
D(3) = intensity * (alpha) * (beta);

end

