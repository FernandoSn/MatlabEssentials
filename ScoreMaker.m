function [Scores] = ScoreMaker(Blocks)

%% z-score, auROC, FanoFactor

    for unit = 1:size(Blocks.FR.Pre,2)
%         Scores.BlankRate.Pre(unit) = nanmean(Blocks.FR.Pre{MO,unit});
%         Scores.BlankSD.Pre(unit) = nanstd(Blocks.FR.Pre{MO,unit});
%         Scores.BlankRate.Post(unit) = nanmean(Blocks.FR.Post{MO,unit});
%         Scores.BlankSD.Post(unit) = nanstd(Blocks.FR.Post{MO,unit});
        
        % z-Score
        for valve = 1:size(Blocks.FR.Pre,1)
            Scores.zScore.Pre(valve,unit) = (nanmean(Blocks.FR.Pre{valve,unit})-...
                nanmean(Blocks.Blank.Pre{valve,unit}))./nanstd(Blocks.Blank.Pre{valve,unit});
            Scores.zScore.Pre(isinf(Scores.zScore.Pre)) = NaN;
            Scores.zScore.Pre(isnan(Scores.zScore.Pre)) = 0;
            Scores.zScore.Post(valve,unit) = (nanmean(Blocks.FR.Post{valve,unit})-...
                nanmean(Blocks.Blank.Post{valve,unit}))./nanstd(Blocks.Blank.Post{valve,unit});
            Scores.zScore.Post(isinf(Scores.zScore.Post)) = NaN;
            Scores.zScore.Post(isnan(Scores.zScore.Post)) = 0;
        end
        
        % auROC and p-value for ranksum
        for valve = 1:size(Blocks.FR.Pre,1)
            [Scores.auROC.Pre(valve,unit), Scores.AURp.Pre(valve,unit)] = RankSumROC(Blocks.FR.Pre{valve,unit},...
                Blocks.Blank.Pre{valve,unit});
            [Scores.auROC.Post(valve,unit), Scores.AURp.Post(valve,unit)] = RankSumROC(Blocks.FR.Post{valve,unit},...
                Blocks.Blank.Post{valve,unit});
        end
        
        % raw rate
        for valve = 1:size(Blocks.FR.Pre,1)
            Scores.RawRate.Pre(valve,unit) = nanmean(Blocks.FR.Pre{valve,unit});
            Scores.RawRate.Post(valve,unit) = nanmean(Blocks.FR.Post{valve,unit});
            Scores.BlankRate.Pre(valve,unit) = nanmean(Blocks.Blank.Pre{valve,unit});
            Scores.BlankRate.Post(valve,unit) = nanmean(Blocks.Blank.Post{valve,unit});
        end
    end

