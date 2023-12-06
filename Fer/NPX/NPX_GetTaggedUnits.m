function [idx,idxBool,SigIdx,SigBool] = NPX_GetTaggedUnits(RasterLaser)

PSTpost = [0,0.1];
PSTpre = [-0.1,0];
PST = [PSTpre(1), PSTpost(2)];
BinSize = 0.002;

noBins = diff(PST) ./ BinSize;
CPEdges(1) = noBins/2 - (0.004/BinSize);
CPEdges(2) = CPEdges(1) + (0.026/BinSize);


trials = 1:length(RasterLaser{1,1,1});


NPXMCSR = NPX_GetMultiCycleSpikeRate(RasterLaser,trials,PSTpost);
NPXMCSRPr = NPX_GetMultiCycleSpikeRate(RasterLaser,trials,PSTpre);

Scores = NPX_SCOmakerPreInh(NPXMCSR,NPXMCSRPr);
%SigInh = (Scores.auROC < 0.5 ) & (Scores.AURp < 10.^-7);
SigInh = (Scores.auROC < 0.5 ) & (Scores.AURp < 0.001);
idx = find(SigInh);



SigBool = SigInh;
SigIdx = idx;

idxBool = false(1,size(RasterLaser,3));

if isempty(idx); return; end;


[~,SUTA] = NPX_Raster2SingleUnitCell(RasterLaser(:,:,SigInh),PST, BinSize, trials,1);

CP = zeros(1,length(SUTA));

for ii = 1:length(SUTA)
    CP(ii) = findchangepts(SUTA{ii});   
end

idx = idx( (CP>=CPEdges(1)) & (CP<CPEdges(2)) );
if isempty(idx); return; end;
idxBool(idx) = true;



