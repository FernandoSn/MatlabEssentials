function NPXMCSR = OLDNPX_GetMultiCycleSpikeRate(NPXSpikes, PREXmat, Valves,depthclu,DepthRange)


%Deprecated_used for my very first NPX recording only.
%Important: PREXmat needs to be corrected first.
%Prov func to get the MCSR of NPX data. MCSR is the input to the SCO
%functions to get the significant odor-pairs.

%for now I will use only 1 conc and 1 cycle and sequential (non-random) odor pres.
%I will create a 2D cell array

%if nargin > 3
   depthclu = sortrows(depthclu,2);
   NPXSpikes.cids = depthclu(:,1)';
%end

if nargin > 4
    
    NPXdepthRangeIdx = find(depthclu(:,2) >= DepthRange(1)...
        & depthclu(:,2)<=DepthRange(2));
    NPXdepthRangeIdx = [NPXdepthRangeIdx(1),NPXdepthRangeIdx(end)];
    
    NPXSpikes.cids = NPXSpikes.cids(NPXdepthRangeIdx(1):NPXdepthRangeIdx(2));
    
end

%Conc = 1;
Cycle = 1;
Trials = length(PREXmat)/Valves;
Units = length(NPXSpikes.cids);
NPXMCSR = cell(Valves,Units);



for valve = 1:Valves
    
    trial = 1;
    for trialIdx = valve:Valves:(Trials*Valves)
        
        for unit = 1:Units
         
            PREXIni = PREXmat(trialIdx,Cycle);
            PREXEnd = PREXmat(trialIdx,Cycle+1);
            SpikesCount = NPXSpikes.st(NPXSpikes.clu == NPXSpikes.cids(unit));
            SpikesCount = sum((SpikesCount > PREXIni) & (SpikesCount <= PREXEnd));
            NPXMCSR{valve,unit}(trial) = SpikesCount./(PREXEnd - PREXIni);
            
        end
        trial = trial + 1;
    end
end

