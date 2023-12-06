function [ auROC, p ] = RankSumROC( Control, Stimulus )
% Use matlab's ranksum function to get to an auROC for comparing PSTHs
[p,~,stats] = ranksum(Stimulus,Control);
auROC = (stats.ranksum - length(Stimulus)*(length(Stimulus)+1)/2)/(length(Stimulus)*length(Control));
if isnan(p)
    p = 1;
end
end

