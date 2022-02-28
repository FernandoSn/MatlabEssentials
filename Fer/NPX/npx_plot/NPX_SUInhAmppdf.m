function NPX_SUInhAmppdf(Raster,ValveTimes, Resp,InhTimes,PREX,POSTX,Fs,PST,trials,NamePDF)

poisson = true;

Colors = winter;
%Colors = cool;
Colors = Colors(1:42:end,:);
Colors = [0,0,0;Colors];

%Colors = Colors([1,2,8],:);

inhamp = NPX_GetInhAmplitude(ValveTimes, Resp,InhTimes,PREX,POSTX,Fs,PST, trials);

%inhamp = inhamp./max(inhamp);

[~, traindata, ~] = BinRearranger(Raster, PST, PST(2) - PST(1), trials);
%[~, traindata] = NPX_GetSingleInhTD(Raster,ValveTimes, PREX, POSTX, trials);

%traindata = traindata + 2;

odors = size(traindata,1) ./ length(trials);

units = size(traindata,2);
% alpha = fliplr(1/length(trials):1/length(trials):1);
if poisson == true
    %Tinhamp = exp(inhamp);
    Ttraindata = log(traindata);
else
    %Tinhamp = inhamp;
    Ttraindata = traindata;
end

for unit = 1:units
    
    if mod(unit-1,10) == 0
        figure
        n = 1;
        if units-(unit-1) < 10
            figunits = units-(unit-1);
        else
            figunits = 10;
        end
        set(gcf, 'Position',  [10, 500, 100 * odors, 100 * figunits])
        %set(gcf, 'Position',  [10, 500, 150 * odors, 150])
    end
    
    
    for ii = 1:odors

        idx = trials + (length(trials) * (ii-1));
        subplot(figunits,odors,n);
        n = n+1;
        hold on

        %rho = corr(inhamp(idx),traindata(idx,unit));

%         for kk = 1:length(idx)
% 
%             scatter(inhamp(idx(kk)),traindata(idx(kk),unit),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'MarkerFaceAlpha',alpha(kk),'MarkerEdgeAlpha',alpha(kk));
%             %scatter(kk,inhamp(idx(kk)),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'MarkerFaceAlpha',alpha(kk),'MarkerEdgeAlpha',alpha(kk));
%         end


        if poisson == true
            
            [b,dev,~] = glmfit(inhamp(idx),traindata(idx,unit),'poisson');
            mdl = (b(1) + b(2) * inhamp(idx));
            
        else  
            [b,dev,~] = glmfit(inhamp(idx),traindata(idx,unit),'normal');
            ss = sum((traindata(idx,unit)-mean(traindata(idx,unit))).^2);
            mdl = (b(1) + b(2) * inhamp(idx));
            ssfit = sum((traindata(idx,unit)-mdl).^2);
            dev = (ss - ssfit) ./ ss; %This is R^2           
        end
        
        scatter(inhamp(idx),Ttraindata(idx,unit),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'SizeData',5)
        temp = sortrows([inhamp(idx),mdl]);
        plot(temp(:,1),temp(:,2),'Color','r')

        text(0,max(Ttraindata(:,unit)),['r^2=',num2str(dev)],'fontsize',5)

        %xlim([0 , max(inhamp)])
        %ylim([0 , max(Ttraindata(:,unit))])
        %xlim([0 , 9000])
        %ylim([0 , 7])
        
        
        if ii == 1
            title(['unit ', num2str(unit)]);
            xlabel('Inhalation (au)');
            ylabel('Rate');
        end
        a = get(gca,'XTickLabel');
        set(gca,'XTickLabel',a,'FontName','Times','fontsize',5);
        
    end

end
Figs2PDF(NamePDF);