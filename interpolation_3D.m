function [A,B,C,D,E,F,G,H] = interpolation_3D(x,y,z,intensity)
% For now, 2D and origin is top left back (E)
A = [floor(x),floor(y),ceil(z)];
B = [ceil(x),floor(y),ceil(z)];
C = [floor(x),ceil(y),ceil(z)];
D = [ceil(x),ceil(y),ceil(z)];
E = [floor(x),floor(y),floor(z)];
F = [ceil(x),floor(y),floor(z)];
G = [floor(x),ceil(y),floor(z)];
H = [ceil(x),ceil(y),floor(z)];

alpha = x - A(1);
beta = y - B(2);
gamma = z - E(3);

A(4) = intensity * (1-alpha) * (1-beta) * (gamma);
B(4) = intensity * (alpha) * (1-beta) * (gamma);
C(4) = intensity * (1-alpha) * (beta) * (gamma);
D(4) = intensity * (alpha) * (beta) * (gamma);
E(4) = intensity * (1-alpha) * (1-beta) * (1-gamma);
F(4) = intensity * (alpha) * (1-beta) * (1-gamma);
G(4) = intensity * (1-alpha) * (beta) * (1-gamma);
H(4) = intensity * (alpha) * (beta) * (1-gamma);

end

