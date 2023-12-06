function [w] = gaussianwin(M,sigma)
% http://www.dsprelated.com/freebooks/sasp/Gaussian_Window_Transform.html
n= -(M-1)/2 : (M-1)/2;
w = exp(-n .* n ./ (2 * sigma .* sigma))';

