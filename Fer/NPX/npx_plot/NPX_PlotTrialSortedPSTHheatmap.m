function NPX_PlotTrialSortedPSTHheatmap(Raster,RasterPr,Trials,NamePDF)


%Creates a pdf with PSTHs heatmaps sorted based on selected Trial chunks

%Trials = Matrix NoTrialChunks * Trial interval (inclusive endpoints [])
%   ie. Trials = [1:20;101:120], sort based on trials 1 to 20 and 101 to
%   120

%Output PDF contains a heatmap matrix All Valves by Trial chunks

files=dir;
for ii = 1:size(files,1)
    if strcmp(files(ii).name,[NamePDF,'.pdf'])
       error('File exists, choose a different name');
    end
end

%% Get the maps

 rpm = 2; %rows per map
 w = size(Raster,1);
 h = rpm * size(Trials,1);
 
PSTHstructs = cell(size(Trials,1),3); %cell to point at structs.
 
plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;
plotparams.VOI = 1:size(Raster,1);

figure

axheatmap=gobjects(size(Trials,1), size(Raster,1));


for ii = 1:size(PSTHstructs,1)
   
    plotparams.TrialVec = Trials(ii,:);
    
    plotparams.Err = 2;
    
    PSTHstructs{ii,1} = NPX_RasterPSTHPlotter(Raster,[],plotparams);

    plotparams.Err = 4;
    
    PSTHstructs{ii,2} = NPX_RasterPSTHPlotter(RasterPr,[],plotparams);
    
    PSTHstructs{ii,3} = NPX_GetPSTHstructZscored(PSTHstructs{ii,1}, PSTHstructs{ii,2}, []);
    
end


for ii = 1:size(Trials,1)
    
    offset = rpm * w * (ii-1);
    
    for kk = 1:w
        
        axheatmap(ii,kk) = subplot(h,w,[kk , w+kk] + offset);
        
        if ii == 1
            [PSTHMat,SortedIdx,t] = NPX_GetPSTHheatmap(PSTHstructs{ii,3},kk,0);
        else
            PSTHMat = NPX_GetPSTHheatmap(PSTHstructs{ii,3},kk,0);
        end
            
            imagesc(t,[],PSTHMat(SortedIdx,:));
            colormap(axheatmap(ii,kk),flipud(pink));
            caxis(axheatmap(ii,kk),[-4,4]);
            xlim(axheatmap(ii,kk),[0 1]);
            xticks(axheatmap(ii,kk),[]);
            yticks(axheatmap(ii,kk),[]);
            
            if kk == 1
                title(axheatmap(ii,kk),['trials ',num2str(Trials(ii,1)),' - ',num2str(Trials(ii,end))]);
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
