function NPXMCSR = NPX_GetMultiCycleSpikeRateOld(NPXSpikes, PREXmat, OlfacMat,FixTime,Cycle)


%Deprecated. Very slow function.

%% Important: NPXSpikes must be sorted by depth. loadKSdirGoodUnits do this by default.

%Important: N by M PREXmat. N,total respirations after an event. (FVO)
%                           M, Respiration idx. that is first, second or
%                           third respiration.

%OlfacMat is the output Matrix of the Olfactometer plugin in Open Ephys.

%Prov func to get the MCSR of NPX data. MCSR is the input to the SCO
%functions to get the significant odor-pairs.

%for now I will use only 1 conc and 1 cycle and sequential (non-random) odor pres.
%I will create a 2D cell array


%%
%if nargin > 3
   %%depthclu = sortrows(depthclu,2);
   %%NPXSpikes.cids = depthclu(:,1)';
%end

% if nargin > 4
    
%     NPXdepthRangeIdx = find(depthclu(:,2) >= DepthRange(1)...
%         & depthclu(:,2)<=DepthRange(2));
%     NPXdepthRangeIdx = [NPXdepthRangeIdx(1),NPXdepthRangeIdx(end)];
%     
%     NPXSpikes.cids = NPXSpikes.cids(NPXdepthRangeIdx(1):NPXdepthRangeIdx(2));
    
% end

% Cycle = 1;
RespFS = 2000;
[PREXOdorTimes1,Odors] = NPX_PREX2Odor(PREXmat,OlfacMat,Cycle);

if FixTime(1)
    PREXOdorTimes2 = PREXOdorTimes1 + FixTime(2) * RespFS; %0.3 = first 300ms after resp.
else
    PREXOdorTimes2 = NPX_PREX2Odor(PREXmat,OlfacMat,Cycle+1);
end

PREXOdorTimes1 = PREXOdorTimes1 ./ RespFS; %IMPORTANT :Getting time stamps.
PREXOdorTimes2 = PREXOdorTimes2 ./ RespFS; %IMPORTANT :Getting time stamps.

%Conc = 1;
Trials = size(PREXOdorTimes1,2);
Units = length(NPXSpikes.cids);

Valves = length(Odors); %I put odors/valves but this can be any event.

NPXMCSR = cell(Valves,Units);

for valve = 1:Valves

    for trial = 1:Trials
        
        for unit = 1:Units
         
            PREXIni = PREXOdorTimes1(valve,trial);
            PREXEnd = PREXOdorTimes2(valve,trial);
            SpikesCount = NPXSpikes.st(NPXSpikes.clu == NPXSpikes.cids(unit));
            SpikesCount = sum((SpikesCount > PREXIni) & (SpikesCount <= PREXEnd));
            NPXMCSR{valve,unit}(trial) = SpikesCount./(PREXEnd - PREXIni);
            
        end
    end
end


% for valve = 1:Valves
%     
%     trial = 1;
%     for trialIdx = valve:Valves:(Trials*Valves)
%         
%         for unit = 1:Units
%          
%             PREXIni = PREXmat(trialIdx,Cycle);
%             PREXEnd = PREXmat(trialIdx,Cycle+1);
%             SpikesCount = NPXSpikes.st(NPXSpikes.clu == NPXSpikes.cids(unit));
%             SpikesCount = sum((SpikesCount > PREXIni) & (SpikesCount <= PREXEnd));
%             NPXMCSR{valve,unit}(trial) = SpikesCount./(PREXEnd - PREXIni);
%             
%         end
%         trial = trial + 1;
%     end
% end

