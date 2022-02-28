function [a,b,c] = NPX_SurgeryAngle(m,ang,option)

%ang = angle in degrees

if option == 1
    %m = perpendicular or 'cateto adyacente'
    a = m;
    c = a / cosd(ang);
    b = c * sind(ang);
elseif option == 2
    %m = base or 'cateto opuesto'
    b = m;
    c = b / sind(ang);
    a = c * cosd(ang);
    
elseif option == 3
    %m = hypotenuse
    c = m;
    a = c * cosd(ang);
    b = c * sind(ang);
end