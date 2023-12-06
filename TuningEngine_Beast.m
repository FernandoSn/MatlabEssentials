function [Tuning] = TuningEngine_Beast(KWIKfile,Params,COI)

VOI = Params.VOI;
Conc = Params.Conc;
Series = Params.TOI;

Scores = SCOmaker_Beast(KWIKfile,Series);

% if Shuffle
%     a = Scores.auROC(VOI,Conc,COI,1,tset);
%     b = Scores.AURp(VOI,Conc,COI,1,tset);
%     for V = 1:size(a,1)
%         shuffleselector = randperm(size(a,3));
%         a(V,1,:) = a(V,shuffleselector);
%         b(V,1,:) = b(V,shuffleselector);
%     end
%     Scores.auROC(VOI,Conc,COI,1) = a;
%     Scores.AURp(VOI,Conc,COI,1) = b;
% end

NUMRU = permute(sum(Scores.AURp(VOI,Conc,COI,1)<.05 & Scores.auROC(VOI,Conc,COI,1)>.5),[3 1 2]);
NUMRD = permute(sum(Scores.AURp(VOI,Conc,COI,1)<.05 & Scores.auROC(VOI,Conc,COI,1)<.5),[3 1 2]);
NUMRT = permute(sum(Scores.AURp(VOI,Conc,COI,1)<.05),[3 1 2]);

Upcount = NUMRU.*(NUMRD==0);
Upcount = Upcount(Upcount>0);
Downcount = NUMRD.*(NUMRU==0);
Downcount = Downcount(Downcount>0);
Mixcount = NUMRU.*(NUMRD~=0) + NUMRD.*(NUMRU~=0);
Mixcount = Mixcount(Mixcount>0);

for histbin = 0:length(VOI)
    Tuning.Count.onlyup(histbin+1) = sum(NUMRT==histbin & NUMRU==histbin & NUMRD==0);
    Tuning.Count.onlydown(histbin+1) = sum(NUMRT==histbin & NUMRD==histbin & NUMRU==0);
    Tuning.Count.mixed(histbin+1) = sum(NUMRT==histbin & NUMRU>0 & NUMRD>0);
    Tuning.Count.total(histbin+1) = sum(NUMRT==histbin);
end

% normalize to percentages
Tuning.Pct.onlyup(:) = 100*bsxfun(@rdivide,Tuning.Count.onlyup,sum(Tuning.Count.total));
Tuning.Pct.onlydown(:) = 100*bsxfun(@rdivide,Tuning.Count.onlydown,sum(Tuning.Count.total));
Tuning.Pct.mixed(:) = 100*bsxfun(@rdivide,Tuning.Count.mixed,sum(Tuning.Count.total));
Tuning.Pct.total(:) = 100*bsxfun(@rdivide,Tuning.Count.total,sum(Tuning.Count.total));
