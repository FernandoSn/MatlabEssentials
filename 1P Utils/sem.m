function [se] = sem(x)
se = std(x)/sqrt(size(x,1));