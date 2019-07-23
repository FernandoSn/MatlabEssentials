function [CrossStruct] = CrossCorrWaveBands(WCrossCorrA,WCrossCorrR,freq)


CrossStruct.CrossDriverABands = cell(1,7);
CrossStruct.CrossTargetABands = cell(1,7);

CrossStruct.CrossDriverRBands = cell(1,7);
CrossStruct.CrossTargetRBands = cell(1,7);

CrossStruct.LagDriverABands = cell(1,7);
CrossStruct.LagTargetABands = cell(1,7);

CrossStruct.LagDriverRBands = cell(1,7);
CrossStruct.LagTargetRBands = cell(1,7);

LengthCross = ((size(WCrossCorrA,2)-1) / 2);

CrossDriverA = WCrossCorrA(:,end - LengthCross : end);
CrossTargetA = fliplr(WCrossCorrA(:,1:LengthCross+1));

CrossDriverR = WCrossCorrR(:,end - LengthCross : end);
CrossTargetR = fliplr(WCrossCorrR(:,1:LengthCross+1));


CrossDriverASum = sum(CrossDriverA,2) ./ (LengthCross+1); 
CrossTargetASum = sum(CrossTargetA,2) ./ (LengthCross+1);

CrossDriverRSum = sum(CrossDriverR,2) ./ (LengthCross+1); 
CrossTargetRSum = sum(CrossTargetR,2) ./ (LengthCross+1);  

ind1 = find(freq >= 1,1,'last');
ind2 = find(freq >= 4,1,'last');
ind3 = find(freq >= 7,1,'last');
ind4 = find(freq >= 10,1,'last');
ind5 = find(freq >= 20,1,'last');
ind6 = find(freq >= 50,1,'last');

CrossStruct.CrossDriverABands{2} = sum(CrossDriverASum(ind2:ind1));
CrossStruct.CrossTargetABands{2} = sum(CrossTargetASum(ind2:ind1));
CrossStruct.CrossDriverRBands{2} = sum(CrossDriverRSum(ind2:ind1));
CrossStruct.CrossTargetRBands{2} = sum(CrossTargetRSum(ind2:ind1));

CrossStruct.CrossDriverABands{3} = sum(CrossDriverASum(ind3:ind2));
CrossStruct.CrossTargetABands{3} = sum(CrossTargetASum(ind3:ind2));
CrossStruct.CrossDriverRBands{3} = sum(CrossDriverRSum(ind3:ind2));
CrossStruct.CrossTargetRBands{3} = sum(CrossTargetRSum(ind3:ind2));

CrossStruct.CrossDriverABands{4} = sum(CrossDriverASum(ind4:ind3));
CrossStruct.CrossTargetABands{4} = sum(CrossTargetASum(ind4:ind3));
CrossStruct.CrossDriverRBands{4} = sum(CrossDriverRSum(ind4:ind3));
CrossStruct.CrossTargetRBands{4} = sum(CrossTargetRSum(ind4:ind3));

CrossStruct.CrossDriverABands{5} = sum(CrossDriverASum(ind5:ind4));
CrossStruct.CrossTargetABands{5} = sum(CrossTargetASum(ind5:ind4));
CrossStruct.CrossDriverRBands{5} = sum(CrossDriverRSum(ind5:ind4));
CrossStruct.CrossTargetRBands{5} = sum(CrossTargetRSum(ind5:ind4));

CrossStruct.CrossDriverABands{6} = sum(CrossDriverASum(ind6:ind5));
CrossStruct.CrossTargetABands{6} = sum(CrossTargetASum(ind6:ind5));
CrossStruct.CrossDriverRBands{6} = sum(CrossDriverRSum(ind6:ind5));
CrossStruct.CrossTargetRBands{6} = sum(CrossTargetRSum(ind6:ind5));

CrossStruct.CrossDriverABands{7} = sum(CrossDriverASum(ind6:ind1));
CrossStruct.CrossTargetABands{7} = sum(CrossTargetASum(ind6:ind1));
CrossStruct.CrossDriverRBands{7} = sum(CrossDriverRSum(ind6:ind1));
CrossStruct.CrossTargetRBands{7} = sum(CrossTargetRSum(ind6:ind1));


%%Lag stuff%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CrossStruct.LagDriverABands{2} = sum(CrossDriverA(ind2:ind1,:),1) ./ (ind1-ind2);
CrossStruct.LagTargetABands{2} = sum(CrossTargetA(ind2:ind1,:),1) ./ (ind1-ind2);
CrossStruct.LagDriverRBands{2} = sum(CrossDriverR(ind2:ind1,:),1) ./ (ind1-ind2);
CrossStruct.LagTargetRBands{2} = sum(CrossTargetR(ind2:ind1,:),1) ./ (ind1-ind2);

CrossStruct.LagDriverABands{3} = sum(CrossDriverA(ind3:ind2,:),1) ./ (ind2-ind3);
CrossStruct.LagTargetABands{3} = sum(CrossTargetA(ind3:ind2,:),1) ./ (ind2-ind3);
CrossStruct.LagDriverRBands{3} = sum(CrossDriverR(ind3:ind2,:),1) ./ (ind2-ind3);
CrossStruct.LagTargetRBands{3} = sum(CrossTargetR(ind3:ind2,:),1) ./ (ind2-ind3);

CrossStruct.LagDriverABands{4} = sum(CrossDriverA(ind4:ind3,:),1) ./ (ind3-ind4);
CrossStruct.LagTargetABands{4} = sum(CrossTargetA(ind4:ind3,:),1) ./ (ind3-ind4);
CrossStruct.LagDriverRBands{4} = sum(CrossDriverR(ind4:ind3,:),1) ./ (ind3-ind4);
CrossStruct.LagTargetRBands{4} = sum(CrossTargetR(ind4:ind3,:),1) ./ (ind3-ind4);

CrossStruct.LagDriverABands{5} = sum(CrossDriverA(ind5:ind4,:),1) ./ (ind4-ind5);
CrossStruct.LagTargetABands{5} = sum(CrossTargetA(ind5:ind4,:),1) ./ (ind4-ind5);
CrossStruct.LagDriverRBands{5} = sum(CrossDriverR(ind5:ind4,:),1) ./ (ind4-ind5);
CrossStruct.LagTargetRBands{5} = sum(CrossTargetR(ind5:ind4,:),1) ./ (ind4-ind5);

CrossStruct.LagDriverABands{6} = sum(CrossDriverA(ind6:ind5,:),1) ./ (ind5-ind6);
CrossStruct.LagTargetABands{6} = sum(CrossTargetA(ind6:ind5,:),1) ./ (ind5-ind6);
CrossStruct.LagDriverRBands{6} = sum(CrossDriverR(ind6:ind5,:),1) ./ (ind5-ind6);
CrossStruct.LagTargetRBands{6} = sum(CrossTargetR(ind6:ind5,:),1) ./ (ind5-ind6);

CrossStruct.LagDriverABands{7} = sum(CrossDriverA(ind6:ind1,:),1) ./ (ind1-ind6);
CrossStruct.LagTargetABands{7} = sum(CrossTargetA(ind6:ind1,:),1) ./ (ind1-ind6);
CrossStruct.LagDriverRBands{7} = sum(CrossDriverR(ind6:ind1,:),1) ./ (ind1-ind6);
CrossStruct.LagTargetRBands{7} = sum(CrossTargetR(ind6:ind1,:),1) ./ (ind1-ind6);