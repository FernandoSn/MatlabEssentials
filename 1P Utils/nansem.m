function [nse] = nansem(x)
nse = nanstd(x)./sqrt(sum(~isnan(x)));