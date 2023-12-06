function [PSTH, PSTHtrials, PSTHt] = NPX_PSTHmaker(Raster, PST, BinSize, Trials)

if length(size(Raster)) == 3
    Edges = PST(1):BinSize:PST(2);
    PSTHt = Edges+BinSize/2;
    PSTHt = PSTHt(1:end-1);
    for V = 1:size(Raster,1)
        for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)
                if nargin<4
                    Trials = 1:length(Raster{V,C,U});
                end
                   for T = 1:length(Trials)
                       %Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.001 & Raster{V,C,U}{Trials(T)}<.001) = [];

                       PSTHtrials{V,C,U,T} = histc(Raster{V,C,U}{Trials(T)},Edges);
                       PSTHtrials{V,C,U,T} = PSTHtrials{V,C,U,T}(1:end-1);
                       
                       if isempty(PSTHtrials{V,C,U,T})
                           PSTHtrials{V,C,U,T} = zeros(1,length(Edges)-1);
                       end
                   end
                   PSTH{V,C,U} = sum(cat(1,PSTHtrials{V,C,U,:}));
            end
        end
    end
end

if length(size(Raster)) == 2
    Edges = PST(1):BinSize:PST(2);
    PSTHt = Edges+BinSize/2;
    PSTHt = PSTHt(1:end-1);
    for V = 1:size(Raster,1)
            for U = 1:size(Raster,2)
                if nargin<4
                    Trials = 1:length(Raster{V,U});
                end
                   for T = 1:length(Trials)
                       %Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.001 & Raster{V,C,U}{Trials(T)}<.001) = [];

                       PSTHtrials{V,1,U,T} = histc(Raster{V,U}{Trials(T)},Edges);
                       PSTHtrials{V,1,U,T} = PSTHtrials{V,1,U,T}(1:end-1);
                       
                       if isempty(PSTHtrials{V,1,U,T})
                           PSTHtrials{V,1,U,T} = zeros(1,length(Edges)-1);
                       end
                   end
                   PSTH{V,1,U} = sum(cat(1,PSTHtrials{V,1,U,:}));
            end 
    end
end
end