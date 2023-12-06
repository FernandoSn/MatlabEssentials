function SF = NPX_SimilarityFraction(Raster,PST,Kernelsize,trials)

[~,~,~,TAPure1] = NPX_Raster2SingleUnitCell(Raster(1,:,:),PST, Kernelsize, trials,0);

[~,~,~,TAPure2] = NPX_Raster2SingleUnitCell(Raster(end,:,:),PST, Kernelsize, trials,0);

%TAPure1 = zscore(TAPure1,0,1);
%TAPure2 = zscore(TAPure2,0,1);


SF = zeros(length(trials) .* size(Raster,1), size(TAPure1,1));

for stim = 1:size(Raster,1)
    
    for tr = trials
    
        [~,~,pv] = NPX_Raster2SingleUnitCell(Raster(stim,:,:),PST, Kernelsize, tr,0);
        
        %pv = zscore(pv,0,1);
        
        for t = 1:size(pv,1)
           
            CosSim1 = dot(TAPure1(t,:),pv(t,:))./(norm(TAPure1(t,:))*norm(pv(t,:)));
            CosSim2 = dot(TAPure2(t,:),pv(t,:))./(norm(TAPure2(t,:))*norm(pv(t,:)));
            
            SF(tr + length(trials) * (stim-1),t) = CosSim1 ./ ( CosSim1 + CosSim2);
        end
   
    end
    

end

