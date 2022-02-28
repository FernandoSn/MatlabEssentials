function NPXMCSR = NPX_GetMultiCycleSpikeRate(Raster,Trials, TimeInterval,OlfacMat)


%Raster from VSRasterAlign_Beast
%TimeInterval = PREXmat or scalar(fix interval)

%If TimeInterval is PREXmat, Edge1 is a zero Matrix because the Raster is
%already aligned to inh after odor onset. If a different inh is desired
%then input a Raster aligned to a different timepoint.

if length(TimeInterval) < 3
    
    Edge1 = zeros(size(Raster,1),length(Raster{1,1,1}))+ TimeInterval(1);
    Edge2 = zeros(size(Raster,1),length(Raster{1,1,1}))+ TimeInterval(2);    
else
   
    Edge1 = zeros(size(Raster,1),length(Raster{1,1,1}));
    Edge2 = (NPX_PREX2Odor(TimeInterval,OlfacMat,2) -...
        NPX_PREX2Odor(TimeInterval,OlfacMat,1))./2000;
    
end

Edge1 = Edge1(:,Trials);
Edge2 = Edge2(:,Trials);

NPXMCSR = cell(size(Raster,1),size(Raster,3));

for V = 1:size(Raster,1)
        for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)
                   for T = 1:length(Trials)
                       %Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.005 & Raster{V,C,U}{Trials(T)}<.005) = [];

                       NPXMCSR{V,U}(T) = (histcounts(Raster{V,C,U}{Trials(T)},[Edge1(V,T),Edge2(V,T)]))...
                           ./(Edge2(V,T) - Edge1(V,T));
                       
                   end
            end
        end
end