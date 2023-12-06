PsyCerr = std(cat(3,PsyCC{1},PsyCC{2}),0,3)./sqrt(length(PsyCC));
PsyC = mean(cat(3,PsyCC{1},PsyCC{2}),3);


nMix = 1:size(PsyC,2);


figure
x = 2;
y = 2;
n = 1;
%set(gcf, 'Position',  [10, 500, 100 * x, 90 * y])


plotT{1} = 'Pin-Ace S1';
plotT{2} = 'Pin-Ace S2';
plotT{3} = 'Octans S1';
plotT{4} = 'Octans S2';

NamePDF = 'PsyC2';

for ii = 1:(x*y)

    subplot(x,y,n);
    hold on
    n = n+1;

    %plot(nMix,PsyC(ii,:),'color','k')
    scatter(nMix,PsyC(ii,:),'MarkerFaceColor','k','MarkerEdgeColor','k')
    
    ylim([0,1]);
    xlim([0, size(PsyC,2) + 1 ])
    ylabel('probability')
    xlabel('mixture');
    
    
    title(plotT{ii});
    han = get(gca,'XTickLabel');
    set(gca,'XTickLabel',han,'FontName','Times','fontsize',5);
    
    makepretty;
    
    for k = 1:length(nMix)

        plot([nMix(k) nMix(k)], [PsyC(ii,k) + PsyCerr(ii,k) , PsyC(ii,k) - PsyCerr(ii,k)],'k')
        
    end
    

end

Figs2PDF(NamePDF);
