function PlotCorrFromKS2Struct(NPXSpikes,RefUnit,TarUnit,eventsNPX,Valve)

%NPXSpikes is the output struct of loadKSdirGoodUnits. Steinmetz lib.
% This plots XCorr without SpikeTrainAnalysis Matrix
%Ref and TarUnit are the clu label. KS2 index.

%eventsNPX are FVO and FVC detected y NPX chassis in seconds.
%Valve is a 2 element vecto. first: valve to include
%second: total valves

%Get the spikes of the desired units
RefTrain = NPXSpikes.st(NPXSpikes.clu == RefUnit);
TarTrain = NPXSpikes.st(NPXSpikes.clu == TarUnit);


if nargin == 5
    
    ProvRefTrain = [];
    eventsNPX = eventsNPX(1:2:end); %ignore valve FVC for now.
    IniPeriod = eventsNPX(Valve(1):Valve(2):end);
    EndPeriod = eventsNPX(Valve(1)+1:Valve(2):end);
    
    if Valve(1) == Valve(2); EndPeriod = [EndPeriod;EndPeriod(end)+10];end
    
    for ii = 1:length(IniPeriod)
       
        ProvRefTrain = [ProvRefTrain;RefTrain(IniPeriod(ii) < RefTrain...
            & EndPeriod(ii) > RefTrain)];
        
    end
    RefTrain = ProvRefTrain;
    
end

%Misc Vars
Interval = 1000; %Cumulative XCorrs each 500 Reference spikes
Option = 'CumulativeMat';


CorrMat = SpikeCorr(RefTrain, TarTrain, 1,30,Option,Interval);
RefTrain = ([0;RefTrain])/60; %Get minutes
if size(CorrMat,1) ~= length(RefTrain); RefTrain = [RefTrain(1:Interval:end);RefTrain(end)];end
%CorrMat = CorrMat./max(CorrMat,[],2);
figure;
switch Option
    case 'IntervalCumulativeMat'
        tic;
       for ii = 1:size(CorrMat,1)
            bar(CorrMat(ii,:),'histc');
            ylim([0 max(CorrMat,[],'all')]);
            xlabel([num2str(RefTrain(ii)),' - ',num2str(RefTrain(ii+1))])
            drawnow;
            pause(.9)
       end
       toc;
    case 'CumulativeMat'
        tic;
       for ii = 1:10:size(CorrMat,1)
            bar(CorrMat(ii,:),'histc');
            xlabel(num2str(RefTrain(ii)))
            drawnow;
       end 
       toc;
    
end 

% tic;
% %figure
% %Data = CorrMat(1,:);
% %h = plot(Data,'YDataSource','Data');
% 
% for ii = 1:1:size(CorrMat,1)
%    
%     %Histcorr(CorrMat(ii,:),1,30);
%     bar(CorrMat(ii,:),'histc');
%     ylim([0 max(CorrMat,[],'all')]);
%     %Data=CorrMat(ii,:);
%     %refreshdata(h,'caller')
%     %plot(CorrMat(ii,:))
%     %title(num2str(RefTrain(ii)));
%     %set(h,'Title',num2str(RefTrain(ii)))
%     xlabel(num2str(RefTrain(ii)))
%     drawnow;
%     pause(.4)
%     
% end
% toc






%Histcorr(CorrVec,1,30);