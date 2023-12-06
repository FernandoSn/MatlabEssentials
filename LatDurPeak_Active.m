function [L,LnLR,D,DnLR,P,PnLR] = LatDurPeak_Active(KWIKfiles,Params)

VOI = Params.VOI;
Conc = Params.Conc;
PST = Params.PST;
KernelSize = Params.KS;
Series = Params.TOI;

for R = 1:length(KWIKfiles)
    clear efd
    clear KDF
    efd = EFDmaker_Beast(KWIKfiles{R});
    
    [KDF,~,KDFt,~] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,:),PST,KernelSize,Series);
    
    % get active cells by binned ROC
    
%     [bROC, bROCp] = BinROCMaker_Beast(efd.ValveSpikes.RasterAlign([1 VOI],Conc,:), PST, .02, 1, 1, Series);    
%     for v = 1:(size(KDF,1))
%         for u = 1:size(KDF,3)
%             timeActive(v,u) = sum(bROCp(v+1,1,u,:) < .05 & bROC(v+1,1,u,:) > .5)*0.02;
%             %isActive(v,u) = sum(bROCp(v+1,1,u,:) < .05 & bROC(v+1,1,u,:) > .5);
%         end
%     end
    
    realPST = KDFt>=PST(1) & KDFt<=PST(2);
    KDFt = KDFt(realPST);
    
    TESTVAR = squeeze(efd.ValveSpikes.MultiCycleSpikeRate([1 VOI],Conc,:,1));
    
    for valve = 1:(size(KDF,1))
        for unit = 1:size(KDF,3)
%            if  isActive(valve,unit) == 1
                KDF{valve,1,unit} = KDF{valve,1,unit}(realPST);
                DFR{valve,1,unit} = KDF{valve,1,unit} - nanmean(TESTVAR{1,unit});
                Z{valve,1,unit} = DFR{valve,1,unit}./nanstd(TESTVAR{1,unit});
                [mx{R}(valve,unit),mxt_temp] = max(KDF{valve,1,unit});
                mxt{R}(valve,unit) = KDFt(mxt_temp);
               % mxd{R}(valve,unit) = FWHM(KDFt,KDF{valve,1,unit},0.15);
               mxd{R}(valve,unit) = sum(Z{valve,unit}>2)*mean(diff(KDFt));                
%                 mxd{R}(valve,unit) = timeActive(valve,unit);
%             else
%                 KDF{valve,unit}  = nan(1,length(realPST));
%                 mx{R}(valve,unit) = nan;
%                 mxt{R}(valve,unit) = nan;
%                 mxd{R}(valve,unit) = nan;
%             end
        end
    end
    
    mx_LR{R} = mx{R}(:,:);
    mx_nLR{R} = mx{R}(:,:);
    
    mxt_LR{R} = mxt{R}(:,:);
    mxt_nLR{R} = mxt{R}(:,:);
    
    mxd_LR{R} = mxd{R}(:,:);
    mxd_nLR{R} = mxd{R}(:,:);
end

%% Stack things up

L = cat(2,mxt_LR{:}); L = L(:);
LnLR = cat(2,mxt_nLR{:}); LnLR = LnLR(:);
Nopks = L < (PST(1)+.001) | L > (PST(2)-.001);
Nopks_nLR = LnLR < (PST(1)+.001) | LnLR > (PST(2)-.001);
L(Nopks) = nan;
LnLR(Nopks_nLR) = nan;

P = cat(2,mx_LR{:}); P = P(:);
PnLR = cat(2,mx_nLR{:}); PnLR = PnLR(:);
P(Nopks) = nan;
PnLR(Nopks_nLR) = nan;

D = cat(2,mxd_LR{:}); D = D(:);
DnLR = cat(2,mxd_nLR{:}); DnLR = DnLR(:);
D(Nopks) = nan;
DnLR(Nopks_nLR) = nan;
