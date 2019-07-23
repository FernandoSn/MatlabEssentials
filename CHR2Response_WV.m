clearvars
close all
clc

%% Pick out recording files and put each in one cell

Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_LOpairing.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

%% Experiment-specific information

numPulse = 5;
preTrials = 15;
postTrials = 15;

%% Gather datas

for R = 1:length(KWIKfiles)
    SpikeTimes{R} = SpikeTimesKK(FindFilesKK(KWIKfiles{R}));
    efd(R) = EFDmaker(KWIKfiles{R});
end

%% Identify CHR2+ cells (primary) and synaptically connected (secondary)
% CHR2+ primary if ranksum p <.05, auROC > .7, spike latency after first 
% pulse < 5msec, spike probability to first pulse > .8
% CHR2+ secondary if ranksum p <.05, auROC > .7

for R = 1:length(KWIKfiles)
    [~,~,TypeIdx{R,1},TypeIdx{R,2}] = CHR2Picker(KWIKfiles{R},numPulse);
end

% TypeStack{1} = cat(1,TypeIdx{:,1});
% TypeStack{2} = cat(1,TypeIdx{:,2});

%% Make trial blocks and get some odor response characteristics by blocks 
% Break odor trials into pre-laser and post-laser blocks
% Get Z-score and auROC values for odor response by trial blocks

for R = 1:length(KWIKfiles)
    [Blocks{R},PV{R},UV{R}] = BlockMaker(KWIKfiles{R},preTrials,postTrials);
    if R == 1;
        MO = 3;
    else MO = 1;
    end
    Scores{R} = ScoreMaker(Blocks{R});
end

%% LRC raster plot

figure; j=1;

for R = 1:length(KWIKfiles)
    for unit = 1:length(TypeIdx{R,1})
        subplot(5,3,j)
        plotSpikeRaster(Blocks{R}.Raster.Pre{PV{R},TypeIdx{R,1}(unit)}, 'PlotType','vertline','XLimForCell',[-1 2],'VertSpikeHeight',.5);
        j = j+1;
    end
end

%% LRC waveforms

for k = 1:length(KWIKfiles)
    [WV.ypos{k},WV.pttime{k},WV.asym{k},WV.hfw{k},WV.bigwave{k},WV.ypos_real{k}] = WaveStats(SpikeTimes{R}.Wave);
    WV.ypos{k} = double(WV.ypos{k});
    
    for unit = 1:size(efd(k).ValveSpikes.MultiCycleSpikeRate,2)
        Rate{k}(unit) = (mean(efd(k).ValveSpikes.MultiCycleSpikeRate{1,unit,1}));
    end
end

%%
v = cell2mat(cat(2,WV.ypos(:)));
w = cell2mat(cat(2,WV.hfw(:)));
a = cell2mat(cat(2,WV.asym(:)));
y = cell2mat(cat(2,WV.pttime(:)));
z = log10(cell2mat(cat(2,Rate(:)')))';



figure(1)
clf
printpos([100 100 800 200])
subplot(1,5,1)
x = -2:.2:2;
[n,bins] = histc(z,x);
stairs([x(1),x],[0;n],'r'); hold on;

set(gca,'TickDir','out')
axis square; box off;
% ylim([0 40])

subplot(1,5,2)
x = -150:20:150;
[n,bins] = histc(v,x);
stairs([x(1),x],[0;n],'r'); hold on;

set(gca,'TickDir','out')
axis square; box off;
% ylim([0 40])

subplot(1,5,3)
x = -1:.1:1;
[n,bins] = histc(a,x);
stairs([x(1),x],[0;n],'r'); hold on;

set(gca,'TickDir','out')
axis square; box off;
% ylim([0 40])

subplot(1,5,4)
x = 0:.05:1;
[n,bins] = histc(y,x);
stairs([x(1),x],[0;n],'r'); hold on;

set(gca,'TickDir','out')
axis square; box off;
% ylim([0 40])








