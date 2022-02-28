function NPX_MasterPlot(Raster,RasterPr,LayerIdxMat,NamePDF)


%LayerIdxMat = Matrix (Layers * indices)

%Creates a pdf with correlation matrices, zscored psths and averaged psths


files=dir;
for ii = 1:size(files,1)
    if strcmp(files(ii).name,[NamePDF,'.pdf'])
       error('File exists, choose a different name');
    end
end

%% Params.

trials = 6:length(Raster{1,1,1});
%trials = [6:90,96:110];


SigUnits = false;

if SigUnits
    
    MCSR = NPX_GetMultiCycleSpikeRate(Raster,trials,[0,1]);
    MCSRPr = NPX_GetMultiCycleSpikeRate(RasterPr,trials,[0,1]);
    Scores = NPX_SCOmakerPreInh(MCSR,MCSRPr);
%     Scores = NPX_SCOmaker(MCSR);
    
    SigExcUnits = (Scores.ZScore > 0 | isinf(Scores.ZScore)) & (Scores.AURp < 0.05);
%     SigExcUnits = (Scores.AURp < 0.05);
    
%     SigExcUnits = SigExcUnits(5,:);
    SigExcUnits = sum(SigExcUnits(2:end,:),1) > 0;
%     SigExcUnits = (SigExcUnits(1,:) == 0 ) & (sum(SigExcUnits(2:end,:),1) > 0);
    

    
    fprintf('SigUnits = %d \n',sum(SigExcUnits));
    fprintf('TotalUnits = %d \n',length(SigExcUnits));
    
    Raster = Raster(:,:,SigExcUnits);
    RasterPr = RasterPr(:,:,SigExcUnits);
    
end

%% Page one. PSTHs and zscored heat maps

if isempty(LayerIdxMat)
   LayerIdxMat = [1 , size(Raster,3)]; 
else
    LayerIdxMat = [1 , size(Raster,3);LayerIdxMat];  
end


 rpl = 3; %rows per layer
 h = rpl * size(LayerIdxMat,1);
 w = size(Raster,1);
 
 
plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;

% plotparams.Trials = 1:90;


plotparams.VOI = 1:size(Raster,1);
% plotparams.NPXDepthIdx = [1 , size(Raster,3)];

PSTHstruct = NPX_RasterPSTHPlotter(Raster,[],plotparams);

plotparams.Err = 4; %Gets std instead of bootstrap error to later get the Zscored struct.
PSTHstructPr = NPX_RasterPSTHPlotter(RasterPr,[],plotparams);

figure
for ii = 1:size(LayerIdxMat,1)
    
    PSTHstructZ = NPX_GetPSTHstructZscored(PSTHstruct, PSTHstructPr, LayerIdxMat(ii,1):LayerIdxMat(ii,2));
    MaxPSTHVal = 0;
    
    axpsth=gobjects(1,size(Raster,1));
    axheatmap=gobjects(1,size(Raster,1));
    
    for kk = 1 : size(Raster,1)
        
        offset = ((ii - 1) * rpl * w);

        axpsth(kk) = subplot(h,w,kk + offset);
        [ave,err] = NPX_PlotAveragePSTH(PSTHstruct,kk,LayerIdxMat(ii,1):LayerIdxMat(ii,2),1,[],0);
        peaktemp = max(ave+err);
        
        if peaktemp > MaxPSTHVal; MaxPSTHVal = peaktemp; end
        
        axheatmap(kk) = subplot(h,w,[w+kk , w*2+kk] + offset);
        NPX_GetPSTHheatmap(PSTHstructZ,kk,1);
        
        if ii == size(LayerIdxMat,1) && kk == 1
            
            ylabel(axheatmap(kk),'units')
            xlabel(axheatmap(kk),'time (s)')
            ylabel(axpsth(kk),'rate (hz)')
            
            
            pos = get(axheatmap(kk),'Position');
            c = colorbar('location','south','Position', [pos(1)  pos(2)-0.065  0.78  0.02]);
            c.Label.String = 'z score';
            
                     
        end
    end
    
    ylim(axpsth,[0 ceil(MaxPSTHVal + 1)])


    %560,420

end

wp = 112 * w;
if wp > 900; wp = 900; end

hp = 105 * h;
if hp > 1200; hp = 1200; end

set(gcf,'Position', [100 100 wp hp])
    
   
%% Page two. Correlation matrices


[~, traindata, ~] = BinRearranger(Raster, [0 1], 1, trials);
[~, traindataPr, ~] = BinRearranger(RasterPr, [0 1], 1, trials);


rows = 4;
sidelength = 2; %side of each mat
h = rows * 1; %This will be modified if I include dim reduction techniques or decoding.
w = size(LayerIdxMat,1)*sidelength;


figure


axcorrmat=gobjects(1,size(LayerIdxMat,1));
axavecorrmat=gobjects(1,size(LayerIdxMat,1));

for ii = 1:size(LayerIdxMat,1)

    ZScoredPseudoMat = NPX_GetZScoredPseudoMat(traindata(:,LayerIdxMat(ii,1):LayerIdxMat(ii,2))',length(trials),0,traindataPr(:,LayerIdxMat(ii,1):LayerIdxMat(ii,2))');
    ZScoredPseudoMatAve = NPX_GetZScoredPseudoMat(traindata(:,LayerIdxMat(ii,1):LayerIdxMat(ii,2))',length(trials),1,traindataPr(:,LayerIdxMat(ii,1):LayerIdxMat(ii,2))');
    
    %offset = ((ii - 1) * rpl * w);
    offset = 0; 
    
    loc1 = (ii-1) * sidelength + 1;
    loc2 = loc1 + sidelength + w - 1;
    axcorrmat(kk) = subplot(h,w,[loc1 , loc2] + offset);
    imagesc(corr(ZScoredPseudoMat));
    colormap(axcorrmat(kk),parula)
    caxis(axcorrmat(kk),[0,1])
    xticks(axcorrmat(kk),[])
    yticks(axcorrmat(kk),[])
    
    loc1 = loc1 + sidelength * w;
    loc2 = loc1 + sidelength + w - 1;
    axavecorrmat(kk) = subplot(h,w,[loc1 , loc2] + offset);
    imagesc(corr(ZScoredPseudoMatAve));
    colormap(axavecorrmat(kk),parula)
    caxis(axavecorrmat(kk),[0,1])
    xticks(axavecorrmat(kk),[])
    yticks(axavecorrmat(kk),[])
    
    
    if ii == 1
        
        pos = get(axavecorrmat(kk),'Position');
        c = colorbar('location','south','Position', [pos(1)  pos(2)-0.05  0.78  0.02]);
        %c.Label.String = 'corr coef';
        
    end
    
    
    
    
end

wp = 112 * w;
if wp > 900; wp = 900; end

hp = 105 * h;
if hp > 1200; hp = 1200; end

set(gcf,'Position', [100 100 wp hp])



%% save pdf
TotalFigures = 2;

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


