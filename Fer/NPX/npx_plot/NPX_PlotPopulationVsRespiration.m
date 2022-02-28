function NPX_PlotPopulationVsRespiration(Raster,RasterResp,PST,trials)


Colors = winter;
%Colors = cool;
Colors = Colors(1:42:end,:);
Colors = [0,0,0;Colors];

[~, respvec, ~] = BinRearranger(RasterResp, PST, PST(2) - PST(1), trials);

[~, traindata, ~] = BinRearranger(Raster, PST, PST(2) - PST(1), trials);

odors = size(traindata,1) ./ length(trials);

titlecell = cell(8,1);
titlecell{1} = 'Blank';
titlecell{2} = '100';
titlecell{3} = '90/10';
titlecell{4} = '70/30';
titlecell{5} = '50/50';
titlecell{6} = '30/70';
titlecell{7} = '10/90';
titlecell{8} = '100';


traindata = mean(traindata,2);

figure
set(gcf, 'Position',  [10, 500, 250 * odors, 200])

alpha = fliplr(1/length(trials):1/length(trials):1);
% alpha = ones(1,20);

for ii = 1:odors
    
    idx = (length(trials) * (ii-1)) + 1 : length(trials) * ii;
    subplot(1,odors,ii);
    hold on
    
    rho = corr(respvec(idx),traindata(idx));
    
    for kk = 1:length(idx)
   
        scatter(respvec(idx(kk)),traindata(idx(kk)),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'MarkerFaceAlpha',alpha(kk),'MarkerEdgeAlpha',alpha(kk));
    
    end
    text(1,max(traindata) -1,['r=',num2str(rho)])
    
%     xlim([0 , max(respvec)])
%     ylim([0 , max(traindata)])
    xlim([0 , 10])
    ylim([0 , 10])
    xlabel('Respiration rate')
    ylabel('Population rate')
    %title
    
end