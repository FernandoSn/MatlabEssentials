clearvars
close all
clc

%% Pick out recording files and put each in one cell

Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_LOpairing.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

%% Experiment-specific information

numPulse = 5;

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
    TypeStack{R} = cat(2,TypeIdx{R,1},TypeIdx{R,2});  % stack CHR2+ and synaptic within an experiment, each cell is one experiment
end

%% Break SpikeTimes.tsec into pre- and post-pairing trial blocks

for R = 1:length(KWIKfiles)
    numTrials(R) = size(efd(R).LaserTimes.LastPulseOff{1},2);
    firstPulseOn(R) = efd(R).LaserTimes.LaserOn{1}(1);
    lastPulseOff(R) = efd(R).LaserTimes.LastPulseOff{1}(numTrials(R));
    for unit = 1:length(TypeStack{R})
        SpikeTime_Pre_idx{unit,R} = SpikeTimes{R}.tsec{TypeStack{R}(unit)} < firstPulseOn(R);
        SpikeTime_Pre{unit,R} = SpikeTimes{R}.tsec{TypeStack{R}(unit)}(SpikeTime_Pre_idx{unit,R});
        SpikeTime_Post_idx{unit,R} = SpikeTimes{R}.tsec{TypeStack{R}(unit)} > lastPulseOff(R);
        SpikeTime_Post{unit,R} = SpikeTimes{R}.tsec{TypeStack{R}(unit)}(SpikeTime_Post_idx{unit,R});
    end
end

% for R = 1:length(KWIKfiles)
%     x = SpikeTime_Pre(:,R);
%     SpikeTime_Pre(:,R) = x(~cellfun(@isempty, x));
% end
% SpikeTime_Pre = SpikeTime_Pre(~cellfun(@isempty, SpikeTime_Pre));

%% Make cross-correlograms

% the function: [CCG, CCGt, CCGe, CCGi, CCGul, CCGll, CCGn] = CCGmaker(SpikeTimes, BinWidth, HalfWidth, Alpha)

HalfWidth = .03; % 60 msec of spike data
BinWidth = .0005; % 0.5 msec bins

for R = 1:length(KWIKfiles)
    if size(TypeStack{R},2) > 1
    [CCG_pre{R}, CCGt_pre{R}, CCGe_pre{R}, ~, ~, ~, ~] = CCGmaker(SpikeTime_Pre(:,R), BinWidth, HalfWidth, 0.05);
    [CCG_post{R}, CCGt_post{R}, CCGe_post{R}, ~, ~, ~, ~] = CCGmaker(SpikeTime_Post(:,R), BinWidth, HalfWidth, 0.05);
    end
end

% %% Plot post-pairing cross-correlograms
% 
% for R = 1:length(KWIKfiles)
%     signiCCG{R} = CCG_post{R}(CCGe_post{R});
% end
% 
%     bar(CCGt_post{1,2},CCG_post{1,2}{2,4},'k');
        
        
        
        
        
        
    