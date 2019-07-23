clearvars
close all
clc

%% For plotting average PSTHs
% KWIKfiles{1} = 'Z:\expt_sets\major\180511\epochs\180511-011_bank1.result-1.hdf5';
KWIKfiles{1} = 'Z:\fernando\190611\epochs\190611-001_bank1.result-1.hdf5';

%% Collect spike rates and pre-odor spike rates for each trial
for k = 1:length(KWIKfiles)
    [a,b] = fileparts(KWIKfiles{k});
    D = dir(fullfile(a,'\bhv\*.bh_prm'));
    [~,I] = sort([D.datenum]);
    paramfile = D(I(end)).name;
    load(fullfile(a,'\bhv\',paramfile),'-mat');
    
    % map odor channels to efd entries
    [Y,VOI] = sort(params.odorchannels);
    COI = 1:length(params.odorconc);
    
    efd(k) = EFDmaker(KWIKfiles{k});
    
    
    %% Collect and stack up pcx KDFS
    KDF = [];
    KernelSize = 0.01;
    PST = [-1 2];
    
    for od = 1:length(VOI)
        [KDF{k,od},~,KDFt,~] = KDFmaker_Beast(efd(k).ValveSpikes.RasterAlign(VOI(od),COI,2:end),PST,KernelSize,1:10);
        KDF{k,od} = squeeze(KDF{k,od})';
    end
end

%% First plot trial types without cell response types
figure(1)
printpos([100 100 1200 300])
clf

clear Kstack
for od = 1:length(VOI)
    subplot(2,6,od)
    Kstack{od} = cell2mat(cat(2,KDF{:,od})');


realPST = KDFt>=PST(1) & KDFt<=PST(2);

plot(KDFt(realPST),smooth(mean(Kstack{1}(:,realPST)),100),'color',[.8 .8 .8]) % mo
hold on
plot(KDFt(realPST),smooth(mean(Kstack{od}(:,realPST)),100),'color',[.1 .1 .6]) % mo

axis square
box off
% ylim([0 15])
xlim(PST)
end

%% Scores
figure(2)
printpos([400 400 500 500])
clf

permVec = [3,1,2];

[Scores,efd] = SCOmaker_Beast(KWIKfiles{k},{1:10});

temp = Scores.RawRate(VOI,:,2:end,1);
temp = sort(temp(:),'descend');
RateLimit = ceil(temp(2));

subplot(2,4,[1 5])

imagesc(permute(squeeze(Scores.RawRate(:,:,2:end,1)),permVec))
ax{1} = gca;
% coloration
HT = hot(32);
HT = HT(1:end-4,:);
colormap(ax{1},HT)
caxis([0 RateLimit]);
set(gca,'YTick',[],'XTick',[]);

subplot(2,4,[2 6])
imagesc(permute(squeeze(Scores.auROC(:,:,2:end,1)),permVec))
ax{2} = gca;

CT = flipud(cbrewer('div','RdBu',64)); CT = CT(4:end-3,:);
colormap(ax{2},CT)
caxis([0 1]);
set(gca,'YTick',[],'XTick',[]);

subplot(2,4,[3.2 4])
axis square
% plot(sum(squeeze(Scores.AURp(2:end,:,2:end,1))'<.05)./length(squeeze(Scores.AURp(2:end,:,2:end,1))'<.05),'k.','markersize',20)
sigs = permute(squeeze(Scores.AURp(2:end,:,2:end,1)),permVec)<.05;
ups = permute(squeeze(Scores.AURp(2:end,:,2:end,1)),permVec)<.05 & permute(squeeze(Scores.auROC(2:end,:,2:end,1)),permVec)>.5;
downs = permute(squeeze(Scores.AURp(2:end,:,2:end,1)),permVec)<.05 & permute(squeeze(Scores.auROC(2:end,:,2:end,1)),permVec)<.5;


sigs = squeeze(sum(sigs));
ups = squeeze(sum(ups));
downs = squeeze(sum(downs));


plot((sigs)./length(sigs),'k.','markersize',20)
hold on;
plot((ups)./length(ups),'r.','markersize',20)
plot((downs)./length(downs),'b.','markersize',20)

xlim([0 5])
ylim([0 .5])
box off

subplot(2,4,[7.2 8])
SparseVar = squeeze(Scores.RawRate(2:end,:,2:end,1));
[SL, SP] = Sparseness(SparseVar);
plot(SP,'k.','markersize',20)
xlim([0 5])
ylim([0 1])
box off
