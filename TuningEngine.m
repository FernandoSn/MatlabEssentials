function [Tuning] = TuningEngine(KWIKfile,VOI,COI,tset,Trials,Shuffle)

[Scores,~] = SCOmaker(KWIKfile,{Trials});

if Shuffle
    a = Scores.auROC(VOI,COI,1,tset);
    b = Scores.AURp(VOI,COI,1,tset);
    for V = 1:size(a,1)
        shuffleselector = randperm(size(a,2));
        a(V,:) = a(V,shuffleselector);
        b(V,:) = b(V,shuffleselector);
    end
    Scores.auROC(VOI,COI,1,tset) = a;
    Scores.AURp(VOI,COI,1,tset) = b;
end

NUMRU = (sum(Scores.AURp(VOI,COI,1,tset)<.05 & Scores.auROC(VOI,COI,1,tset)>.5))';
NUMRD = (sum(Scores.AURp(VOI,COI,1,tset)<.05 & Scores.auROC(VOI,COI,1,tset)<.5))';
NUMRT = (sum(Scores.AURp(VOI,COI,1,tset)<.05))';

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
Tuning.Pct.onlyup(:,tset) = 100*bsxfun(@rdivide,Tuning.Count.onlyup',sum(Tuning.Count.total'))';
Tuning.Pct.onlydown(:,tset) = 100*bsxfun(@rdivide,Tuning.Count.onlydown',sum(Tuning.Count.total'))';
Tuning.Pct.mixed(:,tset) = 100*bsxfun(@rdivide,Tuning.Count.mixed',sum(Tuning.Count.total'))';
Tuning.Pct.total(:,tset) = 100*bsxfun(@rdivide,Tuning.Count.total',sum(Tuning.Count.total'))';
end