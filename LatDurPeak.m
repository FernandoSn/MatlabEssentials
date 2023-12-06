function [L,LnLR,D,DnLR,P,PnLR] = LatDurPeak(KWIKfiles,Params)

VOI = Params.VOI;
Conc = Params.Conc;
PST = Params.PST;
KernelSize = Params.KS;

for R = 1:length(KWIKfiles)
    clear efd
    clear KDF
    efd = EFDmaker_Beast(KWIKfiles{R});
    LRcells = LRcellFinalizer(KWIKfiles{R});
    LR_idx{1} = LRcells.primLR;
    LR_idx{2} = sort([LRcells.nonLR,LRcells.secLR]);
    [KDF,~,KDFt,~] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,LR_idx{1}),PST,KernelSize);
    [KDF_nLR,~,~,~] = KDFmaker_Beast(efd.ValveSpikes.RasterAlign(VOI,Conc,LR_idx{2}),PST,KernelSize);
    
    realPST = KDFt>=PST(1) & KDFt<=PST(2);
    KDFt = KDFt(realPST);
    
    for valve = 1:(size(KDF,1))
        for unit = 1:size(KDF,3)
            if ~isempty(KDF{valve,1,unit})
                KDF{valve,1,unit} = KDF{valve,1,unit}(realPST);
                [mx{R}(valve,unit),mxt_temp] = max(KDF{valve,1,unit});
                mxt{R}(valve,unit) = KDFt(mxt_temp);
                mxd{R}(valve,unit) = FWHM(KDFt,KDF{valve,1,unit},.5);
            else
                KDF{valve,unit}  = nan(1,length(realPST));
                mx{R}(valve,unit) = nan;
                mxt{R}(valve,unit) = nan;
                mxd{R}(valve,unit) = nan;
            end
        end
    end
    
    for valve = 1:(size(KDF_nLR,1))
        for unit = 1:size(KDF_nLR,3)
            if ~isempty(KDF_nLR{valve,1,unit})
                KDF_nLR{valve,1,unit} = KDF_nLR{valve,1,unit}(realPST);
                [mx_nLR{R}(valve,unit),mxt_temp] = max(KDF_nLR{valve,1,unit});
                mxt_nLR{R}(valve,unit) = KDFt(mxt_temp);
                mxd_nLR{R}(valve,unit) = FWHM(KDFt,KDF_nLR{valve,1,unit},.5);
            else
                KDF_nLR{valve,unit}  = nan(1,length(realPST));
                mx_nLR{R}(valve,unit) = nan;
                mxt_nLR{R}(valve,unit) = nan;
                mxd_nLR{R}(valve,unit) = nan;
            end
        end
    end
end

%%

L = cat(2,mxt{:}); L = L(:);
LnLR = cat(2,mxt_nLR{:}); LnLR = LnLR(:);
Nopks = L < (PST(1)+.001) | L > (PST(2)-.001);
Nopks_nLR = LnLR < (PST(1)+.001) | LnLR > (PST(2)-.001);
L(Nopks) = nan;
LnLR(Nopks_nLR) = nan;

P = cat(2,mx{:}); P = P(:);
PnLR = cat(2,mx_nLR{:}); PnLR = PnLR(:);
P(Nopks) = nan;
PnLR(Nopks_nLR) = nan;

D = cat(2,mxd{:}); D = D(:);
DnLR = cat(2,mxd_nLR{:}); DnLR = DnLR(:);
D(Nopks) = nan;
DnLR(Nopks_nLR) = nan;
