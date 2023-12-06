function MACGetZTransformsOdor(SpikesReference, SpikesTarget, efd, SigStruct, BinSize, epoch, Shuffles, Shifts)

ValveReference = GetValveSpikes(SpikesReference,efd,0);
ValveTarget = GetValveSpikes(SpikesTarget,efd,1);
ValveTimes = efd.ValveTimes.FVSwitchTimesOn;
Valves = size(ValveReference,1);
TotalTrials = size(ValveReference{1},1);
NoBins = (epoch / BinSize) .* 2;

OdorCell = cell(Valves,1);

for ii = 1:size(OdorCell,1)

    OdorCell{ii} = ...
        {zeros(size(SigStruct.LeadEx,1),NoBins),...
        zeros(size(SigStruct.LagEx,1),NoBins),...
        zeros(size(SigStruct.BothEx,1),NoBins),...
        zeros(size(SigStruct.LeadIn,1),NoBins),...
        zeros(size(SigStruct.LagIn,1),NoBins),...
        zeros(size(SigStruct.BothIn,1),NoBins),...
        zeros(size(SigStruct.ExIn,1),NoBins)};

end

for Odor = 1:Valves
% for Odor = 1:1
    
    
    for ii = 1:size(SigStruct.LeadEx,1)
        
        if SigStruct.LeadEx(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.LeadEx,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.LeadEx(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.LeadEx(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.LeadEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LeadEx(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.LeadEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LeadEx(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.LeadEx(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.LeadEx(ii,3)},...
                        SigStruct.LeadEx(ii,2), SigStruct.LeadEx(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;


            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);


            OdorCell{Odor}{1}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.LagEx,1)
        
        if SigStruct.LagEx(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.LagEx,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.LagEx(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.LagEx(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.LagEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LagEx(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.LagEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LagEx(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.LagEx(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.LagEx(ii,3)},...
                        SigStruct.LagEx(ii,2), SigStruct.LagEx(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{2}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.BothEx,1)
        
        if SigStruct.BothEx(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u\n',Odor,ii,size(SigStruct.BothEx,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.BothEx(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.BothEx(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.BothEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.BothEx(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.BothEx(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.BothEx(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.BothEx(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.BothEx(ii,3)},...
                        SigStruct.BothEx(ii,2), SigStruct.BothEx(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{3}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.LeadIn,1)
        
        if SigStruct.LeadIn(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.LeadIn,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.LeadIn(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.LeadIn(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.LeadIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LeadIn(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.LeadIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LeadIn(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.LeadIn(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.LeadIn(ii,3)},...
                        SigStruct.LeadIn(ii,2), SigStruct.LeadIn(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{4}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.LagIn,1)
        
        if SigStruct.LagIn(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.LagIn,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.LagIn(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.LagIn(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.LagIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LagIn(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.LagIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.LagIn(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.LagIn(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.LagIn(ii,3)},...
                        SigStruct.LagIn(ii,2), SigStruct.LagIn(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{5}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.BothIn,1)
        
        if SigStruct.BothIn(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.BothIn,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.BothIn(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.BothIn(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.BothIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.BothIn(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.BothIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.BothIn(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.BothIn(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.BothIn(ii,3)},...
                        SigStruct.BothIn(ii,2), SigStruct.BothIn(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{6}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end

    for ii = 1:size(SigStruct.ExIn,1)
        
        if SigStruct.ExIn(ii,1) == Odor

        fprintf('Valve %u LeadEx correlation %u of %u total pairs\n',Odor,ii,size(SigStruct.ExIn,1));
        
        
        ShuffleMatrix = [];
        ShiftMatrix = [];
        CorrVec= zeros(1,NoBins);
        CorrCount = 0;

        for Trial = 1:TotalTrials

            fprintf('Trial number %u\n',Trial);

            if numel(ValveReference{Odor}{Trial}{SigStruct.ExIn(ii,2)}) ~= 0 &&...
            numel(ValveTarget{Odor}{Trial}{SigStruct.ExIn(ii,3)}) ~= 0

                [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{SigStruct.ExIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.ExIn(ii,3)}, BinSize,epoch,CorrVec,CorrCount);

                ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{SigStruct.ExIn(ii,2)},...
                    ValveTarget{Odor}{Trial}{SigStruct.ExIn(ii,3)}, BinSize, Shuffles,epoch)];
                
                ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference{Odor}{Trial}{SigStruct.ExIn(ii,2)},...
                        ValveTarget{Odor}{Trial}{SigStruct.ExIn(ii,3)},...
                        SigStruct.ExIn(ii,2), SigStruct.ExIn(ii,3),Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

            end

        end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(ShuffleStd) ~= 0
            
            CorrVec = CorrVec/CorrCount;

            ShuffleMatrix = mean(ShuffleMatrix,1);
            ShiftMatrix = mean(ShiftMatrix,1);
            
            OdorCell{Odor}{7}(ii,:) = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);

            end
            
        end

    end
    
end

save('ZVecCorrsOdorMO.mat','OdorCell');