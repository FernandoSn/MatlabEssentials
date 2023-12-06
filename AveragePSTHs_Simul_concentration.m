clearvars
close all
clc

%% For plotting average PSTHs
% turn on Essentials

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\simul\ExperimentCatalog_simul_update.txt';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
Pfiles = T.kwikfile(logical(T.include & strcmp(T.condition,'P')));
Bfiles = T.kwikfile(logical(T.include & strcmp(T.condition,'B')));
pFT = T.FT(logical(T.include) & strcmp(T.condition,'P'));
pLT = T.LT(logical(T.include) & strcmp(T.condition,'P'));
bFT = T.FT(logical(T.include) & strcmp(T.condition,'B'));
bLT = T.LT(logical(T.include) & strcmp(T.condition,'B'));

KernelSize = 0.01;
PST = [-.1 0.6];
%% Collect and stack up pcx KDFS
KDF = [];
clear efd
for k = 1:length(Pfiles)
    if strcmp(T.VOI(k),'A')
        for c = 1:4
            VOI = [1,9]+c;
            efd(k) = EFDmaker(Pfiles{k});
            [KDF{k},~,KDFt,~] = KDFmaker(efd(k).ValveSpikes.RasterAlign(VOI,2:end),PST,KernelSize,pFT(k):pLT(k));
            KDFstack_P{k,c} = reshape(KDF{k},1,[]);
        end
    end
end

%% Collect and stack up bulb KDFS
KDF = [];
clear efd
for k = 1:length(Bfiles)
    if strcmp(T.VOI(k),'A')
        for c = 1:4
            VOI = [1,9]+c;
            efd(k) = EFDmaker(Bfiles{k});
            [KDF{k},~,KDFt,~] = KDFmaker(efd(k).ValveSpikes.RasterAlign(VOI,2:end),PST,KernelSize,bFT(k):bLT(k));
            KDFstack_B{k,c} = reshape(KDF{k},1,[]);
        end
    end
end

%%


figure(1)
clf
printpos([500 400 220 140])

for c = 1:4
    colors = [.2 0 0; 0 0 0]+.8-.2*c;


Pstack = cell2mat(cat(2,KDFstack_P{:,c})');
Bstack = cell2mat(cat(2,KDFstack_B{:,c})');

boundedline(KDFt,mean(Bstack),sem(Bstack),KDFt,mean(Pstack),sem(Pstack),'cmap',colors);

xlim(PST); box off; set(gca,'TickDir','out','XTick',[-.5 0 .5 1],'YTick',[0 5 10 15 20])
ylim([0 20])
end
