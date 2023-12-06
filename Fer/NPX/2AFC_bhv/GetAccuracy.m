function [mAcc,sAcc] = GetAccuracy(OM,isPlot,Trials)

if nargin > 2  
    OM = OM( (Trials(1)<=OM(:,1)) & (Trials(2)>=OM(:,1)) ,:);
end

%OM = OM(OM(:,7) ~= 0,:);
OM = OM((OM(:,7) == 2) | (OM(:,7) == 3),:);

mAcc = mean(OM(:,6) == OM(:,7));

sAcc = smooth(OM(:,6) == OM(:,7),30);
sAcc = sAcc(2:end-1);

if isPlot
    figure
    plot(sAcc)
    ylim([0.4,1]);
    xlabel('trial');
    ylabel('fraction correct');
    makepretty;
end