function NPX_PlotSortedPSTHheatmap(Raster,RasterPr,Valves,NamePDF)


%Creates a pdf with PSTHs heatmaps sorted based on selected Valves

%Valves = vector containing the stimuli to take as reference ie. [1,8] or 1:8 for all valves.

%Output PDF contains a heatmap matrix selectedValves by AllValves

files=dir;
for ii = 1:size(files,1)
    if strcmp(files(ii).name,[NamePDF,'.pdf'])
       error('File exists, choose a different name');
    end
end

%% Get the maps

 rpm = 2; %rows per map
 h = rpm * length(Valves);
 w = size(Raster,1);
 
 
plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;


plotparams.VOI = 1:size(Raster,1);
% plotparams.NPXDepthIdx = [1 , size(Raster,3)];

PSTHstruct = NPX_RasterPSTHPlotter(Raster,[],plotparams);

plotparams.Err = 4;
PSTHstructPr = NPX_RasterPSTHPlotter(RasterPr,[],plotparams);

PSTHstructZ = NPX_GetPSTHstructZscored(PSTHstruct, PSTHstructPr, []);

figure

axheatmap=gobjects(length(Valves),size(Raster,1));

for ii = 1:length(Valves)
    
    
    offset = rpm * w * (ii-1);
    
    axheatmap(ii,Valves(ii)) = subplot(h,w,[Valves(ii) , w+Valves(ii)] + offset);
    
    [PSTHMat,SortedIdx,t] = NPX_GetPSTHheatmap(PSTHstructZ,Valves(ii),0);
    imagesc(t,[],PSTHMat(SortedIdx,:));
    colormap(axheatmap(ii,Valves(ii)),flipud(pink));
    caxis(axheatmap(ii,Valves(ii)),[-4,4]);
    xlim(axheatmap(ii,Valves(ii)),[0 1]);
    
    for kk = 1:w
        
        if kk ~= Valves(ii)
            
            axheatmap(ii,kk) = subplot(h,w,[kk , w+kk] + offset);
        
            PSTHMat = NPX_GetPSTHheatmap(PSTHstructZ,kk,0);
            imagesc(t,[],PSTHMat(SortedIdx,:));
            colormap(axheatmap(ii,kk),flipud(pink));
            caxis(axheatmap(ii,kk),[-4,4]);
            xlim(axheatmap(ii,kk),[0 1]);
            xticks(axheatmap(ii,kk),[]);
            yticks(axheatmap(ii,kk),[]);
            
        end
    end


    %560,420

end



ylabel(axheatmap(ii,1),'units');
xlabel(axheatmap(ii,1),'time (s)');




wp = 112 * w;
if wp > 900; wp = 900; end

hp = 105 * h;
if hp > 1200; hp = 1200; end

set(gcf,'Position', [100 100 wp hp])
    
saveas(gcf,[NamePDF,'.pdf'])

close
