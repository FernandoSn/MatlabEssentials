function Licks = NPX_GetLicks(AnalogLicks)

%Get lick samples using the IRBeam signal.

AnalogLicks = AnalogLicks - mean(AnalogLicks);

Licks = [];
Thresh = std(AnalogLicks) * 2;

ii = 2;

while ii<length(AnalogLicks)
   
    if (AnalogLicks(ii) > Thresh ) && ( AnalogLicks(ii-1) <= Thresh )
       
        Licks = [Licks;ii];
        
        ii = ii + 70; %jump 35ms after a lick. This assumes a Fs of 2000 hz.
        
        
    else
    
        ii = ii + 1;
    
    end
    
end