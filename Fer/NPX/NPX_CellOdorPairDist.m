function [ExcPer,InhPer] = NPX_CellOdorPairDist(Scores,PVal,PlotData,idx,isValve)

%get the distribution of signifcant activatd and supressed cells.

if nargin > 3
    
    if isValve
    
        Scores.AURp = Scores.AURp(idx,:);
        Scores.ZScore = Scores.ZScore(idx,:);
        
    else
        
        Scores.AURp = Scores.AURp(:,idx);
        Scores.ZScore = Scores.ZScore(:,idx);
    
    end
    
end

Valves = size(Scores.AURp,1); %Number of Valves/odors minus blank.
Units = size(Scores.AURp,2);

BoolInh = (Scores.ZScore < 0 | isnan(Scores.ZScore)) & (Scores.AURp < PVal);
% BoolInh = BoolInh(2:end,:);
InhVec = sort(sum(BoolInh,1));

BoolExc = (Scores.ZScore > 0 | isinf(Scores.ZScore)) & (Scores.AURp < PVal);
% BoolExc = BoolExc(2:end,:);
ExcVec = sort(sum(BoolExc,1));

InhPer = zeros(1,Valves+1); %Proportrion vectors.
ExcPer = zeros(1,Valves+1);


for ii = 0:Valves
   
    InhPer(ii+1) = sum(InhVec == ii) / Units * 100;
    ExcPer(ii+1) = sum(ExcVec == ii) / Units * 100;
    
end

if PlotData
%     figure
%     plot(1:Valves,InhPer(2:end),'color',[0, 0.4470, 0.7410],'LineWidth',2);
%     ylabel('% responsive cells')
%     title('Suppressed')
%     xlim([0.5,Valves+0.5])
%     ylim([0,30])
    
    
    figure
    plot(1:Valves,ExcPer(2:end),'color',[0.8500, 0.3250, 0.0980],'LineWidth',2);
    ylabel('% responsive cells')
    title('Activated')
    xlim([0.5,Valves+0.5])
    ylim([0,30])
end

