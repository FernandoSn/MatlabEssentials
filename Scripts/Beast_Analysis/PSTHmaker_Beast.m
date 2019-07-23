function [PSTH, PSTHtrials, PSTHt] = PSTHmaker_Beast(Raster, PST, BinSize, Trials)
Edges = PST(1):BinSize:PST(2);
PSTHt = Edges+BinSize/2;
PSTHt = PSTHt(1:end-1);
if ismatrix(Raster)
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,2)
            if nargin<4 || isempty(Trials)
                Trials = 1:length(Raster{V,U});
            end
            for T = 1:length(Trials)
                PSTHtrials{V,U,T} = histc(Raster{V,U}{Trials(T)},Edges);
                PSTHtrials{V,U,T} = PSTHtrials{V,U,T}(1:end-1);
            end
            PSTH{V,U} = sum(cat(1,PSTHtrials{V,U,:}),3);
            PSTH{V,U} = PSTH{V,U}/BinSize/length(Trials);
            %             end
        end
    end
else
    for V = 1:size(Raster,1)
        for C = 1:size(Raster,2)
            for U = 1:size(Raster,3)  %this computes the number of units
                if nargin<4 || isempty(Trials)
                    Trials = 1:length(Raster{V,C,U});
                end
                for T = 1:length(Trials)
                    PSTHtrials{V,C,U,T} = histc(Raster{V,C,U}{Trials(T)},Edges);
                    PSTHtrials{V,C,U,T} = PSTHtrials{V,C,U,T}(1:end-1);
                end
                PSTH{V,C,U} = sum(cat(1,PSTHtrials{V,C,U,:}),3);
                PSTH{V,C,U} = PSTH{V,C,U}/BinSize/length(Trials);
                %             end
            end
        end
    end
end
end