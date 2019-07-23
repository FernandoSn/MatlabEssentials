function CorrVecShift = SpikeTrialShift(RefValveSpikes, TarValveSpikes, Unit1, Unit2,...
    Trial, BinSize, Shifts,epoch,Valve,ValveTimes)

%if isempty(RefValveSpikes{Valve}{Trial}{Unit1})...
 %       || TarValveSpikes{Valve}{Trial}{Unit2}; return; end

NoBins = (epoch / BinSize) .* 2;

Trials = size(RefValveSpikes{1},1);

    
CorrVecShift = zeros(1,NoBins);

Count = 0;
Divisor = 0;

while Count~=Shifts

    IndShift = randi(Trials);
    if IndShift == Trial; IndShift = IndShift + 1; end
    if IndShift > Trials; IndShift = IndShift - 2; end
    
    if numel(TarValveSpikes{Valve}{IndShift}{Unit2}) ~= 0
        
        RefTrial = ValveTimes{Valve}(Trial);
        ShiftTrial = ValveTimes{Valve}(IndShift);
        
        TarVec = RefTrial + TarValveSpikes{Valve}{IndShift}{Unit2}(1) - ShiftTrial;
            
        CorrVecShift = CorrVecShift + SpikeCorr(RefValveSpikes{Valve}{Trial}{Unit1},...
            TarVec, BinSize, epoch);
        
        Divisor = Divisor + 1;

    
    end
    
    Count = Count +1;
    
end

CorrVecShift = CorrVecShift ./ Divisor;