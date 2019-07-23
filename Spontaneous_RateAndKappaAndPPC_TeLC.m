clearvars
close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
% Catalog = 'Z:\expt_sets\catalogs\ExperimentCatalog_bulb_awk_kx.txt';
for tset = 1:2
    %% Pick out files with 'kwik' in its name and put each in one cell
    Catalogs{1} = 'Z:\expt_sets\catalogs\telc-emx\ExperimentCatalog_tet_bulb_awk_md2016_ctrlside.txt';
    Catalogs{2} = 'Z:\expt_sets\catalogs\telc-emx\ExperimentCatalog_tet_bulb_awk_md2016_tetside.txt';
    
    T = readtable(Catalogs{tset}, 'Delimiter', ' ');
    KWIKfiles = T.kwikfile(logical(T.include));
    Kindex = find(T.include);
    
    
    %% OMNI stuff
    for k = 1:length(KWIKfiles)
        
        
        TOI = T.FT(Kindex(k)):T.LT(Kindex(k));
        [SpikeTimes] = SpikeTimesPro(FindFilesKK(KWIKfiles{k}));
        efd = EFDmaker(KWIKfiles{k});
        
        FVall = cat(2,efd.ValveTimes.FVSwitchTimesOn{:});
        BreathStats = efd.BreathStats;
        SpikeTimes.tsec = SpikeTimes.tsec(2:end);
        SpikeTimes.stwarped = SpikeTimes.stwarped(2:end);
        
        
        StateTime(1) = efd.ValveTimes.FVSwitchTimesOn{1}(TOI(1));
        StateTime(2) = efd.ValveTimes.FVSwitchTimesOn{1}(TOI(end));
        
        TW = StateTime;
        
        CycleEdges = 0:10:360; % plot from inhale to inhale
        %         CycleEdges = -180:10:180; % plot from exhale to exhale
        
        for U = 1:length(SpikeTimes.tsec)
            stwarped = SpikeTimes.stwarped{U}(SpikeTimes.tsec{U}>TW(1) & SpikeTimes.tsec{U}<TW(2));
            for f = 1:length(FVall)
                Toss = stwarped>FVall(f)-2 &  stwarped<FVall(f)+4;
                stwarped(Toss) = [];
            end
            TossTime = 6*sum(FVall>TW(1) & FVall<TW(2));
            
            Awarp = (360*mod(stwarped,BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
            %             Awarp(Awarp>180) = Awarp(Awarp>180)-360; % plot from exhale to exhale
            awrp{k}{U} = Awarp;
            
            if ~isempty(awrp{k}{U})
                [PhaseDist{k}{tset,U},~] = histc(awrp{k}{U},CycleEdges);
                PhaseDist{k}{tset,U} = PhaseDist{k}{tset,U}/sum(PhaseDist{k}{tset,U}); % normalize phase distributions
                Kappa{k}(tset,U) = circ_kappa(deg2rad(awrp{k}{U}));
                Rate{k}(tset,U) = length(awrp{k}{U})/(TW(2)-TW(1)-TossTime);
                cmean{k}(tset,U) = circ_mean(deg2rad(awrp{k}{U}));
                cmean{k}(tset,U) = rad2deg(cmean{k}(tset,U));
                Resultant{k}(tset,U) = circ_r(deg2rad(awrp{k}{U}));
                PhaseTest{k}(tset,U) = circ_rtest(deg2rad(awrp{k}{U}));
                PhaseTest{k}(tset,U) = PhaseTest{k}(tset,U)<.05;
                
                % Pairwise Phase Consistency
                clear x
                [x(:,1),x(:,2)] = pol2cart(deg2rad(awrp{k}{U}),1);
                a = (1-pdist(x,'cosine'));
                ppc{k}(tset,U) = 2*sum(a) / (length(awrp{k}{U})*(length(awrp{k}{U})-1));
                
                
            else
                k
                tset
                U
            end
        end
         awrp{k} = awrp{k}(~cellfun(@isempty,awrp{k}));
        Allspikes{tset,k} = cell2mat(awrp{k}');
    end
end

%%
printpos([100 100 600 200])
figure(1); clf;

subplot(1,3,1)
a = cat(2,Rate{:})';
a(a==0) = nan;
h = bar(1:2,nanmean(a));
hold on
set(h,'FaceColor',[.6 .6 .6])
errbar(1:2,nanmean(a),nansem(a),'k')
% errorb(1:2,nanmean(a),nanstd(a)./sqrt(size(a,1)),'top')
xlim([0 3])
% set(gca,'XTick',[1,2],'XTickLabel',{'ctrl','TeLC'},'TickDir','out','YTick',[0 4])
% ylim([0 4]); box off;

set(gca,'XTick',[1,2],'XTickLabel',{'ctrl','TeLC'},'TickDir','out','YTick',[0 5 10 15])
ylim([0 15]); box off;

[h,p,CI,stats] = ttest2(a(:,1),a(:,2))
title(num2str(p))
%%

subplot(1,3,2)
a = cat(2,Kappa{:})';
a(a==0) = nan;

h = bar(1:2,nanmean(a));
hold on
set(h,'FaceColor',[.6 .6 .6])
errbar(1:2,nanmean(a),nansem(a),'k')
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'ctrl','TeLC'},'TickDir','out','YTick',[0 1])
ylim([0 1]); box off;
[h,p,CI,stats] = ttest2(a(:,1),a(:,2))
title(num2str(p))
%%
subplot(1,3,3)
a = cat(2,ppc{:})';
a(a==0) = nan;

h = bar(1:2,nanmean(a));
hold on
set(h,'FaceColor',[.6 .6 .6])
errbar(1:2,nanmean(a),nansem(a),'k')
xlim([0 3])
set(gca,'XTick',[1,2],'XTickLabel',{'ctrl','TeLC'},'TickDir','out','YTick',[0 .1],'Clipping','off')
ylim([0 .1]); box off;
[h,p,CI,stats] = ttest2(a(:,1),a(:,2))
title(num2str(p))

%%
figure(2); clf;
printpos([100 100 600 200])
for state = 1:2
    subplot(1,2,state)
    A = cell2mat(Allspikes(state,:)');
    all_spike_cmean(state) = circ_mean(deg2rad(A));
    all_spike_result(state) = circ_r(deg2rad(A));
%     rose(deg2rad(A),36);
    [T,R] = rose(deg2rad(A),36);
ax = polarplot(T,100*R/length(A),'k');
rlim([0 5])
end

%%
printpos([200 200 600 400])
figure(3); clf;

subplot(1,3,1) % All individual cell phase distribution
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
set(gca,'YTick',[],'XTick',[0 180 360])
% colorbar

subplot(1,3,2) % All individual cell phase distribution
cla
x = cat(2,PhaseDist{:});
xx = cat(2,x{2,:});
[Y,I] = max(xx);
[YY,II] = sort(I);
imagesc(CycleEdges(1:end-1)+5,1:size(xx,2),xx(1:end-1,II)')
colormap(jet)
caxis([0 0.1])
axis square
hold on 
set(gca,'YTick',[],'XTick',[0 180 360])
% colorbar

subplot(1,3,3)
cla
x = cat(2,PhaseDist{:});
xx = cat(2,x{1,:});
stairs(CycleEdges(1:end-1)+5,mean(xx(1:end-1,:),2),'k')
axis square; box off;
hold on 
set(gca,'XTick',[0 180 360])
ylim([0 0.04])
xlim([0 360])

% subplot(2,2,4)
% cla
x = cat(2,PhaseDist{:});
xx = cat(2,x{2,:});
stairs(CycleEdges(1:end-1)+5,mean(xx(1:end-1,:),2),'color',[0 .7 0])
axis square; box off;
hold on 
set(gca,'XTick',[0 180 360],'clipping','off')
ylim([0 0.04])

plot([0 360],[1/36 1/36],'r:')


%%
d = cat(2,Resultant{:});
f = cat(2,cmean{:});

figure(4); clf;
printpos([100 100 600 200])


subplot(1,2,1)
for n = 1:length(d)
    polarplot([deg2rad(0),deg2rad(f(1,n))],[0 d(1,n)],'k')
    hold on;
    rlim([0 1])
end
polarplot([deg2rad(0),(all_spike_cmean(1))],[0 all_spike_result(1)],'r')

% 
% subplot(2,2,3)
% [T,R] = rose(deg2rad(f(1,:)),36);
% polarplot(T,100*R/length(f),'k')

subplot(1,2,2)
for n = 1:length(d)
    polarplot([deg2rad(0),deg2rad(f(2,n))],[0 d(2,n)],'b')
    hold on;
    rlim([0 1])
end
polarplot([deg2rad(0),(all_spike_cmean(2))],[0 all_spike_result(2)],'r')

% 
% subplot(2,2,4)
% [T,R] = rose(deg2rad(f(2,:)),36);
% polarplot(T,100*R/length(f),'b')
% 

