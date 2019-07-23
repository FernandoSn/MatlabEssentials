function Histcorr(CorrVec,BinSize,epoch)

XAxis = -epoch:BinSize:epoch-BinSize;
figure
bar(XAxis,CorrVec,'histc')
