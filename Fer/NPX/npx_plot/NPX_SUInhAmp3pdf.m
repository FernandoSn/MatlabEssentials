function [Betas,GoodIdx] = NPX_SUInhAmp3pdf(inhamp,label,traindata,NamePDF)

poisson = true;
Betas = [];

Colors = winter;
%Colors = cool;
Colors = Colors(1:42:end,:);
Colors = [0,0,0;Colors];

colorline = 'r';
GoodIdx = [];

%Colors = Colors([1,5],:);

%inhamp = inhamp./max(inhamp);
%odors = size(traindata,1) ./ length(trials);
odors = length(unique(label));

labelCMat = repmat(label,1,odors);
labelCMat = double(labelCMat == 1:odors);
labelCMat = labelCMat(:,2:end);

%[~, traindata] = NPX_GetSingleInhTD(Raster,ValveTimes, PREX, POSTX, trials);

%traindata = traindata + 2;



units = size(traindata,2);
% alpha = fliplr(1/length(trials):1/length(trials):1);
if poisson == true
    %Tinhamp = exp(inhamp);
    Ttraindata = (traindata);
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
        %set(gcf, 'Position',  [10, 500, 100 * odors, 100 * figunits])
        set(gcf, 'Position',  [10, 500, 100 * 1, 100 * figunits])
        %set(gcf, 'Position',  [10, 500, 150 * odors, 150])
    end
    
    subplot(figunits,1,n);
    n = n+1;
    hold on
    
    for ii = 1:odors
        idx = label == ii;       
        scatter(inhamp(idx),Ttraindata(idx,unit),'MarkerFaceColor',Colors(ii,:),'MarkerEdgeColor',Colors(ii,:),'SizeData',5)       
    end
    
    if poisson == true

        %[b,dev,~] = glmfit([inhamp,],traindata(:,unit),'poisson');
        %mdl = (b(1) + b(2) * inhamp);
        %[b,dev,~] = glmfit([inhamp,labelCMat],traindata(:,unit),'poisson');
        
        lastwarn('', '');
        
        stats = fitglm([inhamp,label],traindata(:,unit),'linear','Distribution','poisson','CategoricalVars',2);
        %stats = fitglm(inhamp,traindata(:,unit),'linear','Distribution','poisson');
        
        [~, warnId] = lastwarn();
        
        if(isempty(warnId))
            colorline = 'r';
            GoodIdx = [GoodIdx,unit];
        else
            colorline = 'b';
            
        end
        
        
        b = table2array(stats.Coefficients(:,1));
        dev = stats.Deviance;
        
        mdl = [ones(length(inhamp),1),inhamp,labelCMat] * b;
        %mdl = [ones(length(inhamp),1),inhamp] * b;
        
        Betas = [Betas,b];
        
        
%         [~,dev_noconstant] = glmfit(ones(length(inhamp),1),traindata(:,unit),'poisson','Constant','off');
%         D = dev_noconstant - dev;
%         p = 1 - chi2cdf(D,2);

    else  
        [b,dev,~] = glmfit(inhamp,traindata(:,unit),'normal');
        mdl = (b(1) + b(2) * inhamp);
        
        %ss = sum((traindata(:,unit)-mean(traindata(:,unit))).^2);
        %ssfit = sum((traindata(:,unit)-mdl).^2);
        %dev = (ss - ssfit) ./ ss; %This is R^2           
    end
    
    
    
    
    temp = sortrows([inhamp,exp(mdl)]);
    plot(temp(:,1),temp(:,2),'Color',colorline)

    %text(0,max(Ttraindata(:,unit)),['dev=',num2str(dev)],'fontsize',5)
    text(0,max(Ttraindata(:,unit)),['dev=',num2str(dev)],'fontsize',5)
    %xlim([0 , max(inhamp)])
    %ylim([0 , max(Ttraindata(:,unit))])
    %xlim([0 , 9000])
    %ylim([0 , 7])
    title(['unit ', num2str(unit)]);
    xlabel('Inhalation (au)');
    ylabel('Rate');
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontName','Times','fontsize',5);
end
Figs2PDF(NamePDF);

%save('BetasBin.mat','Betas')