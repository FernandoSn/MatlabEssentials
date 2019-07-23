function [LeadEx,LagEx,BothEx,LeadIn,LagIn,BothIn,ExIn] =...
    MasterSpikeCrossCorr(SpikesReference, SpikesTarget, BinSize, epoch, Shuffles,ZThresh)

LeadEx = [];
LagEx = [];
BothEx = [];
LeadIn = [];
LagIn = [];
BothIn = [];
ExIn = [];

for ii = 2 : size(SpikesReference.tsec,1)
   
    for jj = 2 : size(SpikesTarget.tsec,1)
        
        fprintf('Computing Crosscorrelation... Reference cell %u vs Target cell %u\n',ii,jj);
        
        RawCorrVec = SpikeCorr(SpikesReference.tsec{ii}, SpikesTarget.tsec{jj}, BinSize,epoch);
        [CorrVecShuffle, VecStd] = SpikeShuffle(SpikesReference.tsec{ii},...
            SpikesTarget.tsec{jj}, BinSize, Shuffles,epoch);
        
        CorrectedVec = (RawCorrVec-CorrVecShuffle)./(VecStd);
        
        
        exEr = 0;
        inEr = 0;
        
        if sum(CorrectedVec(1:4)>ZThresh) && sum(CorrectedVec(5:8)>ZThresh)
            
            BothEx = [BothEx;ii,jj];
            
            exEr = 1;
            
        elseif sum(CorrectedVec(1:4)>ZThresh)
            
            LagEx = [LagEx;ii,jj];
            
            exEr = 1;
            
        elseif sum(CorrectedVec(5:8)>ZThresh)
            
            LeadEx = [LeadEx;ii,jj];
            
            exEr = 1;
            
        end
        
        if sum(CorrectedVec(1:4)<-ZThresh) && sum(CorrectedVec(5:8)<-ZThresh)
            
            BothIn = [BothIn;ii,jj];
            
            inEr = 1;
            
        elseif sum(CorrectedVec(1:4)<-ZThresh)
            
            LagIn = [LagIn;ii,jj];
            
            inEr = 1;
            
        elseif sum(CorrectedVec(5:8)<-ZThresh)
            
            LeadIn = [LeadIn;ii,jj];
            
            inEr = 1;
            
        end
            
            
        if exEr && inEr
            
            ExIn = [ExIn;ii,jj];
            
        end
        
    end
    
end

save('CrosscorrData.mat','LeadEx','LagEx','BothEx','LeadIn','LagIn','BothIn','ExIn');