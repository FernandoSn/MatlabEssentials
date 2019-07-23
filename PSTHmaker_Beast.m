function [PSTH, PSTHtrials, PSTHt] = PSTHmaker_Beast(Raster, PST, BinSize, Trials)
    Edges = PST(1):BinSize:PST(2);
    PSTHt = Edges+BinSize/2;
    PSTHt = PSTHt(1:end-1);
    for V = 1:size(Raster,1)
        for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)
                if nargin<4 || isempty(Trials)
                    Trials = 1:length(Raster{V,C,U});
                end
                   for T = 1:length(Trials)
                       Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.005 & Raster{V,C,U}{Trials(T)}<.005) = [];

                       PSTHtrials{V,C,U,T} = histc(Raster{V,C,U}{Trials(T)},Edges);
                       PSTHtrials{V,C,U,T} = PSTHtrials{V,C,U,T}(1:end-1);
                   end
                   PSTH{V,C,U} = sum(cat(1,PSTHtrials{V,C,U,:}));
            end
        end
    end
end