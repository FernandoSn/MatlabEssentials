function PlotSimMatsScript7(Raster,Trials,Z,NamePDF)

%plots as a function of units

n = 1; %Fig Counter

PST = [0 3];
BinSize = 0.1;
kernelSize = 0.2;

[ltd, td,~,n_bins] = NPX_GetTD(Raster, PST, BinSize, Trials,true,kernelSize);
if Z; td = zscore(td); end


Time = PST(1):BinSize:PST(2);

figure
x = 10;
y = 8;
%set(gcf, 'Position',  [10, 500, 100 * x, 100 * y])
set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])


%freq = [20,15,10,8];


for ii = 1:n_bins
    
    temptd = td(:,ii:n_bins:end);
    %rho = NPX_GetSimMatrix(td(trials,:), 'corr');
    proj = NPX_EigenProjection(NPX_GetSimMatrix(temptd, 'corr'),1:2);
    n = PlotFigs(temptd,ltd,proj,x,y,n,['t ',num2str(Time(ii)),'-',num2str(Time(ii)+BinSize)]);
    
end


Figs2PDF(NamePDF);
end

function n = PlotFigs(td,ltd,proj,x,y,n,tl)
    
    
    rho = NPX_GetSimMatrix(td, 'corr');   
%     TACorrMat = NPX_GetTrialAveragedSimMat(rho, ltd);
    
    TACorrMat = NPX_GetTrialAveragedVecSimMat(td, ltd,'corr');
    
    n = SetSubplot(x,y,n);
    imagesc(TACorrMat)
    colorbar
    SetFigParams(true,tl);
    
    n = SetSubplot(x,y,n);
    %plot([0,1,3,5,7,9,10],TACorrMat(1:end,1))
    plot(TACorrMat(1:end,1))
    hold on
    %plot([0,1,3,5,7,9,10],TACorrMat(1:end,end))
    plot(TACorrMat(1:end,end))
    SetFigParams(false,'');
    
    n = SetSubplot(x,y,n);
    hold on
    ScatterPlot(proj,ltd)
    SetFigParams(false,'');
    
    n = SetSubplot(x,y,n);
    hold on
    proj = NPX_EigenProjection(rho,1:2);
    ScatterPlot(proj,ltd)
    SetFigParams(false,'');

end

function ScatterPlot(proj,ltd)
    
    
    odors = unique(ltd);
    Colors = winter;
    %Colors = cool;
    
    idx = 1:floor(256./(length(odors)-1)):256;
    if numel(idx) < numel(odors); idx = [idx,256];end
    
    Colors = Colors(idx,:);
    %Colors = [0,0,0;Colors];
    
%     Colors = [0, 0.4470, 0.7410;
%           	0.8500, 0.3250, 0.0980;
%           	0.9290, 0.6940, 0.1250;
%           	0.4940, 0.1840, 0.5560;
%           	0.4660, 0.6740, 0.1880;
%           	0.3010, 0.7450, 0.9330;
%           	0.6350, 0.0780, 0.1840;
%             0,0,0];
%     Colors = Colors(1:4,:);

    for ii = 1:length(odors)
        idx = ltd == odors(ii);       
        scatter(proj(idx,1),proj(idx,2),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'SizeData',5)       
    end

end

function SetFigParams(isMat,txt)

if isMat
   
    xticks([])
    yticks([])
end

title(txt);

a = get(gca,'XTickLabel');
set(gca,'XTickLabel',a,'FontName','Times','fontsize',5);

end

function n = SetSubplot(x,y,n)
if n > (x*y)
    figure
    set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])
    n = 1;
end

subplot(x,y,n);
n = n+1;
end