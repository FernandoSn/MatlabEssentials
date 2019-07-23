function [KDF, KDFtrials, KDFt, KDFe] = KDFmaker_Beast(Raster, PST, KernelSize, Trials)

if ismatrix(Raster)
     for V = 1:size(Raster,1)     %this computes the number of valves
        for U = 1:size(Raster,2)  %this computes the number of units???
            if nargin<4
                Trials = 1:9;
                %Trials = 1:length(Raster{V,U});
            end
            clear RA
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
else % Beast stuff.. concentration is second dimension
    for V = 1:size(Raster,1)     %this computes the number of valves
        for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)  %this computes the number of units
                clear RA
                if nargin<4
                    Trials = 1:length(Raster{V,C,U});
                end
                if ~isempty(Raster{V,C,U}) && ~isempty(Trials)
                    for T = 1:length(Trials)
                        RA(T).Times = Raster{V,C,U}{Trials(T)};
                        if ~isempty(RA(T).Times)
                            KDFtrials{V,C,U,T} = psth(RA(T),KernelSize,'n',PST,0);
                        else
                            RA(T).Times = nan;
                            KDFtrials{V,C,U,T} = psth(RA(T),KernelSize,'n',PST,0);
                        end
                    end
                    if sum(~cellfun(@isempty,{RA.Times}))>0
                        [KDF{V,C,U},KDFt,KDFe{V,C,U}] = psth(RA,KernelSize,'n',PST);
                    end
                end
            end
        end
    end
end

