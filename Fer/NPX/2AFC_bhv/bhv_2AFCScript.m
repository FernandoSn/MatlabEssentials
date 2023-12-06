[TrialBias,AllBias] = GetBiasedLick(OM,StMCC);
[RT,LL] = GetLickorNoLick(OM);

[mAcc,sAcc] = GetAccuracy(OM,true);
[RLP,RLCount,TotalTrials] = GetRightLickPr(OlfacMat,true);
% 
% [mAcc,sAcc] = GetAccuracy(OM,true,[30,80]);
% [RLP,RLCount,TotalTrials] = GetRightLickPr(OlfacMat,true,[30,80]);

[DelayBias,DelayFrac] = GetAnticipTrials(OM);