units = 1:size(Raster,3);
%trials = 1:15;
%trials = 6:25;
%trials = 16:30;
trials = 1:70;
regname = 'pPCx';

t1 = [regname,num2str(units(1)),'-',num2str(units(end)),'TbTCorrT', num2str(trials(1)),'-',num2str(trials(end))];
t2 = [regname,num2str(units(1)),'-',num2str(units(end)),'CorrT', num2str(trials(1)),'-',num2str(trials(end))];
t3 = [regname,num2str(units(1)),'-',num2str(units(end)),'EigT', num2str(trials(1)),'-',num2str(trials(end))];

[ltd, td] = BinRearranger(Raster(:,:,units), [0 1], 1, trials);
td = zscore(td);
rho = NPX_GetSimMatrix(td, 'corr');figure
imagesc(rho)
makepretty;
xticks([])
yticks([])
colorbar;
caxis([-0.6,0.6]);
saveas(gcf,t1)
saveas(gcf,[t1,'.tiff'])

TACorrMat = NPX_GetTrialAveragedVecSimMat(td,ltd);figure;
imagesc(TACorrMat)
makepretty;
xticks([])
yticks([])
colorbar;
caxis([-0.6,0.6]);
saveas(gcf,t2)
saveas(gcf,[t2,'.tiff'])


proj = NPX_EigenProjection(NPX_GetSimMatrix(zscore(td), 'corr'),1:2);
NPX_ScatterPlot(proj,15,false,false,rgbmap('blue','red'))
makepretty;
xticks([])
yticks([])
colormap(rgbmap('blue','red'))
colorbar;
h=colorbar;
set(h,'XTickLabel',{'Pin',' ',' ',' ',' ','Ace',});
saveas(gcf,t3)
saveas(gcf,[t3,'.tiff'])

close all