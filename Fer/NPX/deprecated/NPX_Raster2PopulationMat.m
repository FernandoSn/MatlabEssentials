function [PopulationMat, TrialAveraged, MaxPM,MaxTA] = NPX_Raster2PopulationMat(Raster)

%Raster from VSRasterAlign_Beast.

%PopulationMat = Matrix of Odor-Trials x Units-Time.
%TrialAvergared Matrix of Odors  Unit-Time.

%Deprecated.

PST = [-1,2];
Kernelsize = 0.02;

units = 1:size(Raster,3);
valves = 1:size(Raster,1);
trials = 1:length(Raster{1,1,1});

[KDF, KDFtrials, KDFt] = KDFmaker(Raster(valves,units), PST, Kernelsize, trials);
realPST = KDFt>=PST(1) & KDFt<=PST(2);

timebins = length(KDF{1,1}(realPST));

PopulationMat = zeros(length(valves) * length(trials), length(units) * timebins);
TrialAveraged = zeros(length(valves), length(units) * timebins);

MaxPM = zeros(length(valves) * length(trials), length(units));
MaxTA = zeros(length(valves), length(units));

for valve = 1:length(valves)
    
   
    for unit = 1:length(units)
        
        col = ( (unit-1) * timebins + 1) : ( unit * timebins );
        
        TrialAveraged(valve,col) = KDF{valve,unit}(realPST);
        
        MaxTA(valve,unit) = max(KDF{valve,unit}(realPST));
       
        for trial = 1:length(trials)
           
            row = (valve - 1) * length(trials) + trial;
            
            PopulationMat(row,col) = KDFtrials{valve,unit,trial}(realPST);
            
            MaxPM(row,unit) = max(KDFtrials{valve,unit,trial}(realPST));
            
        end
        
    end
    
end






