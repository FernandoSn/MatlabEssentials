function MovTimes = NPX_FindMov(MedianTrace,Fs,PREX)



Thresh = 750;
SkipSecs = 1.5;
MovTimes = [];

ii = 1;

while ii <= length(MedianTrace)
        
    if MedianTrace(ii) > Thresh
        
        stamp = ii/Fs;
        
        if ~any((abs(PREX-stamp)) < 0.1)
            
            MovTimes = [MovTimes,stamp];
            ii = ii + SkipSecs * Fs;
         
        else
            ii = ii+1;
        end
        
    else
        
        ii = ii+1;
        
    end
    
end