function [CCG, CCGt, CCGe, CCGi, CCGul, CCGll, CCGn] = CCGmaker(SpikeTimes, BinWidth, HalfWidth, Alpha)
%% CCG{m,n} -> Spikes of cell n relative to spikes of cell m.
% Peak on the right side of CCG{m,n} means that cell m fired before cell n.

CCGt = -HalfWidth:BinWidth:HalfWidth;

% 
% HW = ones(1,1+.005/BinWidth);
% HW(ceil(length(HW)/2)) = .42;
% HW = HW/sum(HW);

for m = 1:length(SpikeTimes.tsec)
    for n = (m+1):length(SpikeTimes.tsec)
        if sum(ismember(SpikeTimes.tsec{n},SpikeTimes.tsec{m})) > .8*length(SpikeTimes.tsec{n})
            CCG{m,n} = [];
        elseif isempty(SpikeTimes.tsec{m}) || isempty(SpikeTimes.tsec{n})
            CCG{m,n} = [];
        else
            offsets = crosscorrelogram(SpikeTimes.tsec{m}', SpikeTimes.tsec{n}', [-HalfWidth HalfWidth]);
            [CCG{m,n},~] = hist(offsets,CCGt);
            
            % this tries to fill in the "censored period". this could
            % matter a lot if using a local threshold
%             CCG{m,n}(ceil(length(CCGt)/2)) = nanmean(CCG{m,n}(ceil(length(CCGt)/2)-1));
            
            CCG{m,n}([1,end]) = nan;
            CCG{n,m} = fliplr(CCG{m,n});
            
            [pvals, pred, qvals] = cch_conv(CCG{m,n}', .005*2/BinWidth);
            
            CCGn{m,n} = CCG{m,n}/(nanmean(CCG{m,n}(CCGt>.01 | CCGt<.01))); % normalized?
            
            % eliminate infinity or close.
            if (mean(CCG{m,n}(CCGt>.01 | CCGt<.01))) < .001
                CCGn{m,n} = nan(size(CCG{m,n})); % 
            end
            CCGn{n,m} = fliplr(CCGn{m,n});
            
            % to get global significance
            % (including correction for multiple comparisons), check crossing of alpha
            % divided by the number of bins tested
            CorrectAlpha = Alpha/sum(CCGt>.001 & CCGt<.004);
            
            %             x = conv(CCG{m,n},HW,'same');
            ul = poissinv(1-CorrectAlpha, pred);
            ul = max(ul(CCGt>-HalfWidth+.005 & CCGt<HalfWidth-.005));
            ll = poissinv(CorrectAlpha, pred);
            ll = min(ll(CCGt>-HalfWidth+.005 & CCGt<HalfWidth-.005));
            
            
            % local threshold
%             CCGe(m,n) = sum(CCGt>.001 & CCGt<.004 & pvals'<CorrectAlpha)>0;
%             CCGi(m,n) = sum(CCGt>.001 & CCGt<.004 & qvals'<CorrectAlpha)>0;
%             
%             CCGe(n,m) = sum(CCGt<-.001 & CCGt>-.004 & pvals'<CorrectAlpha)>0;
%             CCGi(n,m) = sum(CCGt<-.001 & CCGt>-.004 & qvals'<CorrectAlpha)>0;
            
            % global threshold
            CCGe(m,n) = sum(CCGt>.001 & CCGt<.004 & CCG{m,n}>ul)>0;
            CCGi(m,n) = sum(CCGt>.001 & CCGt<.004 & CCG{m,n}<ll)>0;
            
            CCGe(n,m) = sum(CCGt<-.001 & CCGt>-.004 & CCG{m,n}>ul)>0;
            CCGi(n,m) = sum(CCGt<-.001 & CCGt>-.004 & CCG{m,n}<ll)>0;
            
            CCGul{m,n} = ul*ones(size(CCGt));
            CCGll{m,n} = ll*ones(size(CCGt));
        end
    end
end


