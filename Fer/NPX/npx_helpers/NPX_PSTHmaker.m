function [PSTHtrials] = NPX_PSTHmaker(Raster, PSTs, Trials,isLat)

%isLat = true for latencies
    if isLat
        maxLat = max(cell2mat(PSTs),[],'all');
    end
    for V = 1:size(Raster,1)
        for U = 1:size(Raster,3)
%             if ~isempty(Raster{V,U})
%                 if nargin<4 || isempty(Trials)
%                     Trials = 1:length(Raster{V,U});
%                 end
                for T = 1:length(Trials)
                    
                    %Raster{V,U}{Trials(T)}(Raster{V,U}{Trials(T)}>-.001 & Raster{V,U}{Trials(T)}<.001) = [];
                    
                    if isLat
                        
                        PSTHtrials{V,U,T} = find((Raster{V,1,U}{Trials(T)}>PSTs{V,T}(1)) & (Raster{V,1,U}{Trials(T)}<PSTs{V,T}(2)),1);
                   
                       if isempty(PSTHtrials{V,U,T})
                           PSTHtrials{V,U,T} = maxLat+0.1;
                       else    
                           PSTHtrials{V,U,T} = Raster{V,1,U}{Trials(T)}(PSTHtrials{V,U,T});
                       end
                        
                    else
                    
                        PSTHtrials{V,U,T} = histc(Raster{V,1,U}{Trials(T)},[PSTs{V,T}(1), PSTs{V,T}(2)]);

                        dt = (PSTs{V,T}(2) - PSTs{V,T}(1));
                        PSTHtrials{V,U,T} = PSTHtrials{V,U,T}(1:end-1)./dt;
                    
                    end
                end
%             end
        end
    end
end