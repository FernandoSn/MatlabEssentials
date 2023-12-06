function HeatMapper(matrix,Title,YAxis,colorLim)

figure
ax = gca;
imagesc(matrix)
caxis(colorLim);
% coloration
CT = flipud(cbrewer('div','RdBu',64));
CT = CT(3:end-3,:);
colormap(CT)
colorbar('Peer', ax); 
ax.YTick = [];
ax.XTick = [];
ax.Title.String = Title;
ax.YLabel.String = {YAxis;['(n= ',num2str(size(matrix,1)),')']};
% ax.XAxis.TickLabels = XAxis;
% ax.XTickLabelRotation = 45;
grid off