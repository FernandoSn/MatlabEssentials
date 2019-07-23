function [PSTH, PSTHtrials, PSTHt] = PSTHcounts(Raster, PST, BinSize, Trials)
    Edges = PST(1):BinSize:PST(2);
    PSTHt = Edges+BinSize/2;
    PSTHt = PSTHt(1:end-1);
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
%             if ~isempty(Raster{V,U})
                if nargin<4 || isempty(Trials)
                    Trials = 1:length(Raster{V,U});
                end
                for T = 1:length(Trials)
                    %                    Raster{V,U}{Trials(T)}(Raster{V,U}{Trials(T)}>-.001 & Raster{V,U}{Trials(T)}<.001) = [];
                    
                    PSTHtrials{V,U,T} = histc(Raster{V,U}{Trials(T)},Edges);
                    PSTHtrials{V,U,T} = PSTHtrials{V,U,T}(1:end-1);
                end
                PSTH{V,U} = sum(cat(1,PSTHtrials{V,U,:}),3);
                PSTH{V,U} = PSTH{V,U}/length(Trials);
%             end
        end
    end
end