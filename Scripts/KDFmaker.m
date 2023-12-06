function [KDF, KDFtrials, KDFt, KDFe] = KDFmaker(Raster, PST, KernelSize, Trials)
     for V = 1:size(Raster,1)     %this computes the number of valves
        for U = 1:size(Raster,2)  %this computes the number of units???
            if nargin<4
                Trials = 1:length(Raster{V,U});
            end
            for T = 1:length(Trials)
                RA(T).Times = Raster{V,U}{Trials(T)};
                if ~isempty(RA(T).Times)
                    KDFtrials{V,U,T} = psth(RA(T),KernelSize,'n',PST,0);
                else
                    RA(T).Times = nan;
                    KDFtrials{V,U,T} = psth(RA(T),KernelSize,'n',PST,0);
                end
            end
            if sum(~cellfun(@isempty,{RA.Times}))>0
                [KDF{V,U},KDFt,KDFe{V,U}] = psth(RA,KernelSize,'n',PST);
            end
        end
     end
end

