
name = 'WMEtBuVal';


% NPX_MasterPlot(Raster1,Raster1Pr,[L2idx(1), L2idx(end);L3idx(1), L3idx(end)],[name,'R1Summary']);
% NPX_MasterPlot(Raster2,Raster2Pr,[L2idx(1), L2idx(end);L3idx(1), L3idx(end)],[name,'R2Summary']);

NPX_MasterPlot(Raster1L2,Raster1L2Pr,[],[name,'R1L2Summary']);
NPX_MasterPlot(Raster2L2,Raster2L2Pr,[],[name,'R2L2Summary']);

NPX_MasterPlot(Raster1L3,Raster1L3Pr,[],[name,'R1L3Summary']);
NPX_MasterPlot(Raster2L3,Raster2L3Pr,[],[name,'R2L3Summary']);


NPX_MasterPlot(Raster1All,Raster1AllPr,[],[name,'R1AllSummary']);
NPX_MasterPlot(Raster2All,Raster2AllPr,[],[name,'R2AllSummary']);


% NPX_PlotSortedPSTHheatmap(Raster2,Raster2Pr,1:8,[name,'R2sortedmap'])

NPX_PlotSortedPSTHheatmap(Raster2L2,Raster2L2Pr,1:8,[name,'R2L2sortedmap'])
NPX_PlotSortedPSTHheatmap(Raster2L3,Raster2L3Pr,1:8,[name,'R2L3sortedmap'])
NPX_PlotSortedPSTHheatmap(Raster2All,Raster2AllPr,1:8,[name,'R2Allsortedmap'])

