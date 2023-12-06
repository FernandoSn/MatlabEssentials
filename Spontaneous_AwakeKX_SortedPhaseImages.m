clearvars
close all
clc

%% For plotting average PSTHs
% turn on Essentials

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_pcx_awk_intensity.txt';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

%% OMNI stuff
for R = 1:length(KWIKfiles)
    KWIKfile = KWIKfiles{R};
    FilesKK=FindFilesKK(KWIKfile);
    SpikeTimes = SpikeTimesKK(FilesKK);
    efd = EFDmaker(KWIKfile);
    FVall = cat(2,efd.ValveTimes.FVSwitchTimesOn{:});
    BreathStats = efd.BreathStats;
    SpikeTimes.tsec = SpikeTimes.tsec(2:end);
    SpikeTimes.stwarped = SpikeTimes.stwarped(2:end);
    
    for tset = 1
        %         if tset == 1
        %             TW = ATW{RecordList(R)};
        %         else
        %             TW = KTW{RecordList(R)};
        %         end
        TW = [efd.ValveTimes.FVSwitchTimesOn{1}(FT(R)) efd.ValveTimes.FVSwitchTimesOn{1}(LT(R))];
        
%         CycleEdges = -180:10:180; % plot from exhale to exhale
        CycleEdges = 0:10:360; % plot from inhale to inhale

        for k = 1:length(SpikeTimes.tsec)
            stwarped = SpikeTimes.stwarped{k}(SpikeTimes.tsec{k}>TW(1) & SpikeTimes.tsec{k}<TW(2));
            for f = 1:length(FVall)
                Toss = stwarped>FVall(f)-2 &  stwarped<FVall(f)+4;
                stwarped(Toss) = [];
            end
            TossTime = 6*sum(FVall>TW(1) & FVall<TW(2));
            
            Awarp = (360*mod(stwarped,BreathStats.AvgPeriod)/BreathStats.AvgPeriod); 
%             Awarp(Awarp>180) = Awarp(Awarp>180)-360; % plot from exhale to exhale
            awrp{R}{k} = Awarp;
            [PhaseDist{R}{tset,k},~] = histc(awrp{R}{k},CycleEdges);
            PhaseDist{R}{tset,k} = PhaseDist{R}{tset,k}/sum(PhaseDist{R}{tset,k}); % normalize phase distributions
            Kappa{R}(tset,k) = circ_kappa(deg2rad(awrp{R}{k}));
            Rate{R}(tset,k) = length(awrp{R}{k})/(TW(2)-TW(1)-TossTime);
            cmean{R}(tset,k) = circ_mean(deg2rad(awrp{R}{k}));
            cmean{R}(tset,k) = rad2deg(cmean{R}(tset,k));
            Resultant{R}(tset,k) = circ_r(deg2rad(awrp{R}{k}));
            PhaseTest{R}(tset,k) = circ_rtest(deg2rad(awrp{R}{k}));
            PhaseTest{R}(tset,k) = PhaseTest{R}(tset,k)<.05;
        end
    end
end

%%
printpos([200 200 600 300])
figure(1); clf;

subplot(1,2,1) % All individual cell phase distribution
cla
x = cat(2,PhaseDist{:});
xx = cat(2,x{1,:});
[Y,I] = max(xx);
[YY,II] = sort(I);
imagesc(CycleEdges(1:end-1)+5,1:size(xx,2),xx(1:end-1,II)')
colormap(jet)
caxis([0 0.1])
axis square
hold on 
set(gca,'YTick',[])
colorbar