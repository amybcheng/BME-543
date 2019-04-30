r = 1;
x = linspace(-r, r, 100);
y = x;
z = x;

[X,Y,Z] = meshgrid(x,y,z);
f = X.^2 + Y.^2 + Z.^2;
