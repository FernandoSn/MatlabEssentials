function [SU, SUTA,td,tda] = NPX_Raster2SingleUnitCell2(Raster,PST,BinSize,KernelSize,trials,isSmooth)




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


%[PSTHTA, PSTHtrials, PSTHt] = PSTHmaker(Raster(valves,units), PST, BinSize, trials);
[PSTHTA, PSTHtrials, PSTHt] = NPX_PSTHmaker(Raster, PST, BinSize, trials);

PSTHTA = reshape(PSTHTA,[size(PSTHTA,1),size(PSTHTA,3)]);
PSTHtrials = reshape(PSTHtrials,[size(PSTHtrials,1),size(PSTHtrials,3),size(PSTHtrials,4)]);


nbins = length(PSTHt);

%PopulationMat = zeros(length(valves) * length(trials), length(units) * timebins);
tda = zeros(length(valves) * nbins, length(units));
%TAPopulationMat = zeros(length(valves), length(units) * timebins);

%MaxPM = zeros(length(valves) * length(trials), length(units));
%MaxTA = zeros(length(valves), length(units));


SU = cell(length(units),1);

SUTA = cell(length(units),1);

% TempSC = zeros(length(valves) * length(trials), timebins);
% TempSCTA = zeros(length(valves), timebins);

td = zeros(length(valves) * nbins * length(trials), length(units));

tt = (PST(end) - PST(1));
kernel = gaussmf(linspace(-tt,tt,nbins),[KernelSize 0])';
kernel = kernel ./ sum(kernel);


for unit = 1:length(units)
    
    SUTA{unit} = cell2mat(PSTHTA(:,unit));
    
    if isSmooth
        for ii = 1:size(SUTA{unit},1)
            SUTA{unit}(ii,:) = conv(SUTA{unit}(ii,:),kernel','same'); 
        end
    end
    
    tda(:,unit) = reshape(SUTA{unit}',[length(valves) * nbins,1]);
    
    
    SU{unit} = [];
    tdtemp = [];
    
    for valve = 1:length(valves)

        temp = cell2mat(PSTHtrials(valve,unit,:));
        temp = reshape(temp,nbins,length(trials));
        
        if isSmooth     
            for ii = 1:size(temp,2)
                
                temp(:,ii) = conv(temp(:,ii),kernel,'same');
                
            end
        end
        
        SU{unit} = [SU{unit};temp'];
        tdtemp = [tdtemp;reshape(temp,[numel(temp),1])];

    end
    
    td(:,unit) = tdtemp;
    %td(:,unit) = reshape(SU{unit}',[numel(SU{unit}),1]);
    
end