function [X,Y] = ElegantUnpair(Z)

sqrtz = floor(Z.^.5);
sqz = sqrtz.^2;
if (Z-sqz) >= sqrtz
    X = sqrtz;
    Y = Z - sqz - sqrtz;
else
    X = Z - sqz;
    Y = sqrtz;
end