function [Proj,V] = NPX_EigenProjection(rho,Vidx)

%Eigenprojection of the similarity matrix.
%rho = similarity matrix
%Vidx = index of eigenvectors to project.

[V,D] = eig(rho);
[~,ind] = sort(diag(D));


ind = flip(ind);

V = V(:,ind);

% D = D(ind,ind);
% V = V*D;

if nargin == 2
    Proj = rho*V(:,Vidx);
else
    Proj = rho*V; 
end