function PlotSimMatsScript5(td,ltd,NamePDF)

%plots as a function of units

n = 1; %Fig Counter

BlockSize = 49;
%BlockSize = 14;




figure
x = 10;
y = 8;
%set(gcf, 'Position',  [10, 500, 100 * x, 100 * y])
set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])


%freq = [20,15,10,8];

ii = 1;
while (ii+BlockSize)<=size(td,2)
    
    units = ii:(ii+BlockSize);
   
    %rho = NPX_GetSimMatrix(td(trials,:), 'corr');
    proj = NPX_EigenProjection(NPX_GetSimMatrix(td(:,units), 'corr'),1:2);
    n = PlotFigs(td(:,units),ltd,proj,x,y,n,['u ',num2str(units(1)),'-',num2str(units(end))]);
    
    ii = ii+1;
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
    Colors = Colors(1:floor(256./(length(odors)-1)):end,:);
    %Colors = [0,0,0;Colors];

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