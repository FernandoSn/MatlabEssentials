function [Z] = ElegantPair(X,Y)

if X >= Y
    Z = X.^2 + X + Y;
else
    Z = Y.^2 + X;
end