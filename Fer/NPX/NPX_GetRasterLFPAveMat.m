function AveMat = NPX_GetRasterLFPAveMat(RasterLFP,Valves,Channels,Trials,Concs)


if nargin < 5
    Concs = 1:size(RasterLFP,2); 
end
if nargin < 4
    Trials = 1:length(RasterLFP{1,1,1});
end
if nargin < 3
    Channels = 1:size(RasterLFP,3); 
end
if nargin < 2
    Valves = 1:size(RasterLFP,1); 
end



AveMat = zeros(length(Channels), length(RasterLFP{1,1,1}{1}));

TempMat = zeros(length(Valves) * length(Concs) * length(Trials), length(RasterLFP{1,1,1}{1}));


for Channel = 1:length(Channels)
    n = 1;
   for Valve = 1:length(Valves)
      
       for Conc = 1:length(Concs)
       
           for Trial = 1:length(Trials)
              
              TempMat(n,:) = RasterLFP{Valves(Valve),Concs(Conc),Channels(Channel)}{Trials(Trial)};
              n = n+1;
               
               
           end
           
       end
   end
    
   AveMat(Channel,:) = mean(TempMat,1);
   
end