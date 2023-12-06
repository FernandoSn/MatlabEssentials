function NPX_GetPSTHpdf(Raster,SpikeTimes,NamePDF,plotparams)

if nargin < 4
    plotparams.PSTH.Axes = 'on';
    plotparams.PSTHparams.Axes = 'on';
    plotparams.OnlyData = false;
    plotparams.VOI = 1:size(Raster,1);
    %plotparams.PSTHparams.PST = [-.3,0.6];
    plotparams.PSTHparams.PST = [-1,3];
    %plotparams.PSTHparams.KernelSize = 0.0040;
    
    
%     plotparams.TrialVec = 1:9;
    
end

if isempty(SpikeTimes)
   
   SpikeTimes.units = num2cell((1:size(Raster,3))');
   SpikeTimes.depth = zeros(size(Raster,3),1);
    
end

NPX_RasterPSTHPlotter(Raster,SpikeTimes,plotparams);

%TotalFigures = ceil((plotparams.NPXDepthIdx(2) - plotparams.NPXDepthIdx(1)+1)./10);
TotalFigures = ceil(size(Raster,3)./10);


names = cell(TotalFigures,1);

for kk = TotalFigures:-1:1

    names{kk} = [num2str(kk),'.pdf'];
    saveas(gcf,names{kk});
    close
end


append_pdfs([NamePDF,'.pdf'],names);

for kk = 1:TotalFigures

    delete(names{kk});

end
