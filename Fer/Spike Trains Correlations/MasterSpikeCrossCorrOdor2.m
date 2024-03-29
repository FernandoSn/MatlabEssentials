function [LeadEx,LagEx,BothEx,LeadIn,LagIn,BothIn,ExIn] =...
    MasterSpikeCrossCorrOdor2(SpikesReference, SpikesTarget, BinSize, epoch, Shuffles,Shifts,ZThresh,efd)

LeadEx = [];
LagEx = [];
BothEx = [];
LeadIn = [];
LagIn = [];
BothIn = [];
ExIn = [];

ValveReference = GetValveSpikes(SpikesReference,efd,0);
ValveTarget = GetValveSpikes(SpikesTarget,efd,1);
ValveTimes = efd.ValveTimes.FVSwitchTimesOn;
Valves = size(ValveReference,1);
TotalTrials = size(ValveReference{1},1);
RefUnits = size(ValveReference{1}{1},1);
TarUnits = size(ValveTarget{1}{1},1);
NoBins = (epoch / BinSize) .* 2;

for Odor = 1:Valves
% for Odor = 1:1
    
    fprintf('Valve number %u\n',Odor);

    for ii = 2 : RefUnits

        for jj = 2 : TarUnits

            fprintf('Computing Crosscorrelation... Reference cell %u vs Target cell %u\n',ii,jj);
            
            ShuffleMatrix = [];
            ShiftMatrix = [];
            CorrVec= zeros(1,NoBins);
            CorrCount = 0;
            
            for Trial = 1:TotalTrials
                
                fprintf('Trial number %u\n',Trial);
                
                if numel(ValveReference{Odor}{Trial}{ii}) ~= 0 &&...
                numel(ValveTarget{Odor}{Trial}{jj}) ~= 0

                    [CorrVec,CorrCount] = SpikeCorrOdor(ValveReference{Odor}{Trial}{ii},...
                        ValveTarget{Odor}{Trial}{jj}, BinSize,epoch,CorrVec,CorrCount);

                    ShuffleMatrix = [ShuffleMatrix;SpikeShuffleOdor(ValveReference{Odor}{Trial}{ii},...
                        ValveTarget{Odor}{Trial}{jj}, BinSize, Shuffles,epoch)];

                    ShiftMatrix = [ShiftMatrix;SpikeTrialShift(ValveReference,...
                        ValveTarget, ii, jj,Trial, BinSize, Shifts,epoch,Odor,ValveTimes)];

                
                end
            
            end
            
            ShuffleStd = std(ShuffleMatrix,1);
            ShiftStd = std(ShiftMatrix,1);
            VecStd = mean([ShuffleStd;ShiftStd]);
            
            if CorrCount ~=0 && sum(VecStd) ~= 0
            
                CorrVec = CorrVec/CorrCount;

                ShuffleMatrix = mean(ShuffleMatrix,1);
                ShiftMatrix = mean(ShiftMatrix,1);

                CorrectedVecFinal = (CorrVec-ShuffleMatrix-ShiftMatrix)./mean(VecStd);



                exEr = 0;
                inEr = 0;

                if sum(CorrectedVecFinal(1:4)>ZThresh) && sum(CorrectedVecFinal(5:8)>ZThresh)

                    BothEx = [BothEx;Odor,ii,jj];

                    exEr = 1;

                elseif sum(CorrectedVecFinal(1:4)>ZThresh)

                    LagEx = [LagEx;Odor,ii,jj];

                    exEr = 1;

                elseif sum(CorrectedVecFinal(5:8)>ZThresh)

                    LeadEx = [LeadEx;Odor,ii,jj];

                    exEr = 1;

                end

                if sum(CorrectedVecFinal(1:4)<-ZThresh) && sum(CorrectedVecFinal(5:8)<-ZThresh)

                    BothIn = [BothIn;Odor,ii,jj];

                    inEr = 1;

                elseif sum(CorrectedVecFinal(1:4)<-ZThresh)

                    LagIn = [LagIn;Odor,ii,jj];

                    inEr = 1;

                elseif sum(CorrectedVecFinal(5:8)<-ZThresh)

                    LeadIn = [LeadIn;Odor,ii,jj];

                    inEr = 1;

                end


                if exEr && inEr

                    ExIn = [ExIn;Odor,ii,jj];

                end
            end

        end

    end
end
 save('CrossCorrDataOdorONOFF.mat','LeadEx','LagEx','BothEx','LeadIn','LagIn','BothIn','ExIn');