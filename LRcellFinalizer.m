function [LR] = LRcellFinalizer(KWIKfile)

% [efd] = EFDmaker_Beast(KWIKfile,'bhv');

%% Load file

[a,b] = fileparts(KWIKfile);
LRfile = [a,filesep,b,'.lr'];
if exist(LRfile,'file')
    load(LRfile,'-mat')
else

%% Run auto cell picker

[LR_idx,nonLR_idx] = LRcellPicker(KWIKfile);

%% Remove questionable LR cells

plotparams.VOI = 'L';
plotparams.PSTHparams.Axes = 'on';
plotparams.PSTHparams.PST = [-2,3];
plotparams.COI = LR_idx;
RasterPSTHPlotter(KWIKfile,plotparams)

prompt = 'Do you want to remove units? ';
remove = input(prompt);

primLR = LR_idx;
if ~isempty(remove)
    for i = 1:length(remove)
        [~,idx] = find(primLR == remove(i));
        primLR(idx) = [];
        secLR(i) = remove(i);
    end
else
    secLR = [];
end
    
%% Add any missed LR cells

close all
clear plotparams.COI
plotparams.COI = nonLR_idx;
RasterPSTHPlotter(KWIKfile,plotparams)

prompt = 'Do you want to add units? ';
add = input(prompt);

primLR = [primLR add];
sort(primLR);

nonLR = nonLR_idx;
for i = 1:length(add)
    [~,idx] = find(nonLR == add(i));
    nonLR(idx) = [];
end


LR.primLR = primLR;
LR.secLR = secLR;
LR.nonLR = nonLR;

    

save(LRfile,'LR')

end