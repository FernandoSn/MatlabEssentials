function PseudoMat = NPX_GetPseudoPopulationMatrix(MCSR,varargin)

%MCSR = Multi cycle Spike Rate by NPX_GetMultiCycleSpikeRate.

Valves = size(MCSR,1); %Number of valves/odors/stimuli

Units = size(MCSR,2);


if ~isempty(varargin)
    TrialVec = varargin{1};
    Trials = length(TrialVec);
else
    Trials = length(MCSR{1,1});
    TrialVec = 1:Trials;
end


PseudoMat = zeros(Units,Valves*Trials);

for unit = 1 : Units
    
    
    TempUnitVec = [];

    for valve = 1 : Valves
       
        TempUnitVec = [TempUnitVec, MCSR{valve,unit}(TrialVec)];
        
    end
    
    PseudoMat(unit,:) = TempUnitVec;
    
end

%[rho,pval] = corr(PseudoMat);
