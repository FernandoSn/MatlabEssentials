function NPXMCSR = NPX_GetMultiCycleSpikeRate2(Raster,Trials,TimeInterval,OM,cond)


%Raster from VSRasterAlign_Beast
%TimeInterval = PREXmat or scalar(fix interval)

%If TimeInterval is PREXmat, Edge1 is a zero Matrix because the Raster is
%already aligned to inh after odor onset. If a different inh is desired
%then input a Raster aligned to a different timepoint.

idx1 = find(OM(:,1) == Trials(1),1,'first');
idx2 = find(OM(:,1) == Trials(end),1,'last');
[ltd,bc] = NPX_GetTrialIdx(OM(idx1:idx2,:),cond,20);

NPXMCSR = cell(length(unique(ltd(bc))),size(Raster,3));
% NPXMCSR = cell(size(Raster,1),size(Raster,3));

ltd = reshape(ltd,[length(Trials),length(ltd)./ length(Trials)]);
bc = reshape(bc,[length(Trials),length(bc)./ length(Trials)]);



Edge1 = zeros(size(Raster,1),length(Raster{1,1,1}))+ TimeInterval(1);
Edge2 = zeros(size(Raster,1),length(Raster{1,1,1}))+ TimeInterval(2);    


Edge1 = Edge1(:,Trials);
Edge2 = Edge2(:,Trials);



%n = 1;

for V = 1:size(Raster,1)
    for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)
                   for T = 1:length(Trials)
                       %Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.005 & Raster{V,C,U}{Trials(T)}<.005) = [];
                        if bc(T,V)
%                            NPXMCSR{V,U}(n) = (histcounts(Raster{V,C,U}{Trials(T)},[Edge1(V,T),Edge2(V,T)]))...
%                                ./(Edge2(V,T) - Edge1(V,T));
                           
                           NPXMCSR{ltd(T,V),U} = [NPXMCSR{ltd(T,V),U},((histcounts(Raster{V,C,U}{Trials(T)},[Edge1(V,T),Edge2(V,T)]))...
                               ./(Edge2(V,T) - Edge1(V,T)))];
                           %n = n+1;
                        end
                       
                   end
                   %n = 1;
            end
    end
end