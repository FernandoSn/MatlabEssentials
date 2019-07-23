function [dur] = FWHM(PSTHt,fx,wlevel)

[pk,lc] = max(fx);
xr = find(fx(lc:end)<pk*wlevel,1);
xl = lc-find(fx(1:lc)<pk*wlevel,1,'last');

stepsize = mean(diff(PSTHt));
if isempty(xr)
    xr = length(fx(lc:end));
end
if isempty(xl)
    xl = lc;
end
    
dur = (xr+xl)*stepsize;