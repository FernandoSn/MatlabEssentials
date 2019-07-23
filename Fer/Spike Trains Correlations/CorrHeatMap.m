function CorrHeatMap(ZMat,BinSize,epoch,cmap)

XAxis = -epoch:BinSize:epoch-BinSize;

% ZMat = MACSortZScores(ZMat,'max'); %Ex
 ZMat = MACSortZScores(ZMat,'min'); %In

figure;imagesc(XAxis,[],ZMat);

colormap(cmap)

%   caxis([0 6]) %Ex
   caxis([-4 0]) %In
  
  hold on
  
   plot(zeros(1,size(ZMat,1)),1:size(ZMat,1), 'Color','w','LineStyle','--','LineWidth',1.2);
   
   plot([XAxis,1000],ones(1,81) * 50, 'Color','w','LineStyle','--','LineWidth',1.2);
  
  