function [SU, SUTA,td,tda] = NPX_Raster2SingleUnitCell(Raster,PST,Kernelsize,trials,option)




%return

%SU, single unit trial by trial cell array
%SUTA, single unit trial averaged cell array

%option = 0, Gaussian kernel.
%option = 1; Raw PSTH.

%PST = [0,1];
%Kernelsize = 1;

%Kernelsize = 0.02; %For KDF

units = 1:size(Raster,3);
valves = 1:size(Raster,1);
%trials = 6:length(Raster{1,1,1});

if option == 0
    [KDF, KDFtrials, KDFt] = KDFmaker(Raster(valves,units), PST, Kernelsize, trials);
elseif option == 1
    [KDF, KDFtrials, KDFt] = PSTHmaker(Raster(valves,units), PST, Kernelsize, trials);
end
realPST = KDFt>=PST(1) & KDFt<=PST(2);

timebins = length(KDF{1,1}(realPST));

%PopulationMat = zeros(length(valves) * length(trials), length(units) * timebins);
tda = zeros(length(valves) * timebins, length(units));
%TAPopulationMat = zeros(length(valves), length(units) * timebins);

%MaxPM = zeros(length(valves) * length(trials), length(units));
%MaxTA = zeros(length(valves), length(units));

td = zeros(length(valves) * timebins * length(trials), length(units));

SU = cell(length(units),1);

SUTA = cell(length(units),1);

% TempSC = zeros(length(valves) * length(trials), timebins);
% TempSCTA = zeros(length(valves), timebins);


for unit = 1:length(units)
    
    SUTA{unit} = cell2mat(KDF(:,unit));
    
    SUTA{unit} = SUTA{unit}(:,realPST);
    
    tda(:,unit) = reshape(SUTA{unit}',[length(valves) * timebins,1]);
    
    
    SU{unit} = [];
    
    for valve = 1:length(valves)

        temp = cell2mat(KDFtrials(valve,unit,:));
        temp = reshape(temp,length(realPST),length(trials));
        
        SU{unit} = [SU{unit};temp(realPST,:)'];

    end
   
    td(:,unit) = reshape(SU{unit}',[numel(SU{unit}),1]);
end






