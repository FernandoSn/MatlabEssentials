function [S,t,f] = PTspecgramMaker(Raster,Trials)
     for V = 1:size(Raster,1)     %this computes the number of valves
        for U = 1:size(Raster,2)  %this computes the number of units???
            if nargin<2
                Trials = 1:length(Raster{V,U});
            end
            for T = 1:length(Trials)
%                 RA(T).Times = Raster{V,U}{Trials(T)};
                [train(T,:),edges] = histcounts(Raster{V,U}{Trials(T)},-1:.0005:2);
            end
            train(:,abs(edges)<.02) = 0;
%             if sum(~cellfun(@isempty,{RA.Times}))>0
                TW = 3;
                ntapers = 2*TW-1;
                params.Fs = 2000;
                params.fpass = [0 100];
                params.tapers = [TW,ntapers];
                params.trialave = 1;
%                 [S{V,U},f] = mtspectrumpb(train',params);
                [S{V,U},t,f] = mtspecgrampb(train',[.3 .02],params);

%             end
        end
     end
end

