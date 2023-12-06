function [wclass,axclass,wodor,edgec] = NPX_GetCorrValues(rho,ltd)

%Get Correlations within class, across class and witin oodor.
%There is a bug, within class includes the odor itself.

SzRho = size(rho,1);

rho(1:SzRho+1:numel(rho)) = nan;

ltd = ltd - min(ltd) + 1;
odors = unique(ltd);

block = false(length(ltd),1);
block(ltd<=(max(odors)/2)) = true;
wcmat = false(SzRho,SzRho);
wcmat(block,block) = true;
wcmat(~block,~block) = true;
axcmat = ~wcmat;

block = false(length(ltd),1);
block(ltd==(max(odors)/2)) = true;
block(ltd==(max(odors)/2)+1) = true;
edgemat = false(SzRho,SzRho);
edgemat(block,block) = true;

wodormat = false(SzRho,SzRho);

for ii = 1:length(odors)
    
    wodormat(ltd==odors(ii),ltd==odors(ii)) = true;
    
end

for ii = 1:SzRho
   
    wcmat(ii,ii:SzRho) = false;
    axcmat(ii,ii:SzRho) = false;
    wodormat(ii,ii:SzRho) = false;
    edgemat(ii,ii:SzRho) = false;
    
end

wcmat(wodormat) = false;
axcmat(wodormat) = false;
edgemat(wodormat) = false;

wclass = rho(wcmat);
axclass = rho(axcmat);
wodor = rho(wodormat);
edgec = rho(edgemat);