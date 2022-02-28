function NPX_PlotPopulationVsInhalationAmp(Raster,ValveTimes, Resp,InhTimes,PREX,POSTX,Fs,PST,trials)

%Colors = winter;
Colors = cool;
Colors = Colors(1:42:end,:);
Colors = [0,0,0;Colors];

%Colors = Colors([1,2,8],:);

inhamp = NPX_GetInhAmplitude(ValveTimes, Resp,InhTimes,PREX,POSTX,Fs,PST, trials);

[~, traindata, ~] = BinRearranger(Raster, PST, PST(2) - PST(1), trials);
%[~, traindata] = NPX_GetSingleInhTD(Raster,ValveTimes, PREX, POSTX, trials);

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
%set(gcf, 'Position',  [10, 500, 150 * odors, 150])

alpha = fliplr(1/length(trials):1/length(trials):1);
% alpha = ones(1,20);

for ii = 1:odors
    
    idx = (length(trials) * (ii-1)) + 1 : length(trials) * ii;
    subplot(1,odors,ii);
    hold on
    
    rho = corr(inhamp(idx),traindata(idx));
    
    for kk = 1:length(idx)
   
        scatter(inhamp(idx(kk)),traindata(idx(kk)),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'MarkerFaceAlpha',alpha(kk),'MarkerEdgeAlpha',alpha(kk));
        %scatter(kk,inhamp(idx(kk)),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'MarkerFaceAlpha',alpha(kk),'MarkerEdgeAlpha',alpha(kk));
    end
    
    [b,~,stats] = glmfit(inhamp(idx),traindata(idx),'normal');
    mdl = (b(1) + b(2) * inhamp(idx));
    temp = sortrows([inhamp(idx),mdl]);
    plot(temp(:,1),temp(:,2),'Color','r')
    
    ss = sum((traindata(idx)-mean(traindata(idx))).^2);
    ssfit = sum((traindata(idx)-mdl).^2);
    rs = (ss - ssfit) ./ ss;
    text(1,max(traindata) -1,['r^2=',num2str(rs)])
    %text(1,7,['r^2=',num2str(rs)])
    %text(1,1,['r^2=',num2str(stats.p(2))])
    
    xlim([0 , max(inhamp)])
    ylim([0 , max(traindata)])
    %xlim([0 , 18000])
    %ylim([0 , 50])
    xlabel('Inhalation (au)')
    ylabel('Population rate')
    title(titlecell{ii})
end