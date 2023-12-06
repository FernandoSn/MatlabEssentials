function [b] =  cellcat3d(a)
b = reshape(cat(1,a{:}),size(a,1),size(a,2),[]);
end