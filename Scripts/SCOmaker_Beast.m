function [Scores,efd] = SCOmaker_Beast(KWIKfile,TrialSets)
% function [Scores,efd] = SCOmaker(KWIKfile,TrialSets)
% This SCOmaker function will give you information for all odor-cell pairs
% about how the odor reponse differs from the blank response. The output
% will be a structure called Scores. These can be further summarized to
% characterize unit responses per experiment. It will also pass along the
% full experiment data (efd) gathered from EFDmaker.
%
% If your experiment contains multiple conditions divided up into sets of
% trials (like awake or anesthetized or laser on and laser off etc..) you
% can indicate that with something like TrialSets{1} = 1:10; TrialSets{2} =
% 21:30; etc... If you don't put in any TrialSets all trials are analyzed
% at once.
%
% Scores output are stored like this:
% Scores.BlankRate and Scores.BlankSD - (Unit,BreathCycle,TrialSet)
% All other Scores - (Valve,Unit,BreathCycle,TrialSet)
% BreathCycle refers to which respiration cycle after odor delivery is
% analyzed. Usually you want to analyze BreathCycle 1 but you could
% potentially care about the evolution of a response past the first cycle.
%
% It's also important to note that scores are calculated on firing RATE not
% spike counts. That is, spike counts are divided by the length of the
% breath cycle.


% %only saves/loads .sco file if all trials are requested
% [a,b] = fileparts(KWIKfile);
% SCOfile = [a,filesep,b,'.sco'];
% if exist(SCOfile,'file') && nargin<2
%     load(SCOfile,'-mat')
% else

%% Here we are gathering information.
% Basically spike counts relative to valve openings and when experimental events occur.
[efd] = EFDmaker_Beast(KWIKfile,'bhv');
%efd = KWIKfile;
% Also if the user doesn't specify any trials to analyze in particular we
% will find the minimum number of trials for a single valve and use those.
mintrials = min(cellfun(@length,efd.ValveTimes.FVSwitchTimesOn));
if nargin < 2
    TrialSets{1} = 1:15;
end

%% Here we will take any measure of the response and give indications of
% how different the odorant response is from valve 1.
% These will include: auROC, p-value for ranksum test, z-score, rate
% change, mean and SD of valve 1 response.

%% Cycles
TESTVAR = efd.ValveSpikes.MultiCycleSpikeRate(:,:,:,:);
%     TESTVAR_select = (TESTVAR(5:12,2:size(TESTVAR,2),:));


for tset = 1:length(TrialSets)
    if ~isempty(TrialSets{tset})
        for Unit = 1:size(TESTVAR,3)
            for Conc = 1:size(TESTVAR,2)
                for Cycle = 1:size(TESTVAR,4)
                    % Blank Rate and SD
                    if ~isempty(efd.ValveTimes.PREXTimes{1,Conc})
                        Scores.BlankRate(Conc,Unit,Cycle,tset) = nanmean(TESTVAR{1,Conc,Unit,Cycle}(TrialSets{tset}));
                        Scores.BlankSD(Conc,Unit,Cycle,tset) = nanstd(TESTVAR{1,Conc,Unit,Cycle}(TrialSets{tset}));
                    end
                    for Valve = 1:size(TESTVAR,1)
                        if ~isempty(efd.ValveTimes.PREXTimes{Valve,Conc})
                            % First Cycle
                            % auROC and p-value for ranksum test
                            [Scores.auROC(Valve,Conc,Unit,Cycle,tset), Scores.AURp(Valve,Conc,Unit,Cycle,tset)] = RankSumROC(TESTVAR{1,end,Unit,Cycle}(TrialSets{tset}),TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}));
                            
                            % Z-Scores based on valve 1 responses vs everything else.
                            Scores.ZScore(Valve,Conc,Unit,Cycle,tset) = (nanmean(TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}))-nanmean(TESTVAR{1,end,Unit,Cycle}(TrialSets{tset})))./nanstd(TESTVAR{1,end,Unit,Cycle}(TrialSets{tset}));
                            Scores.ZScore(isinf(Scores.ZScore)) = NaN;
                            
                            % Rate change based on valve 1 responses vs everything else. The
                            % denominator comes into play here.
                            Scores.RateChange(Valve,Conc,Unit,Cycle,tset) = (nanmean(TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}))-nanmean(TESTVAR{1,end,Unit,Cycle}(TrialSets{tset})));
                            
                            % Raw Rate
                            Scores.RawRate(Valve,Conc,Unit,Cycle,tset) = nanmean(TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}));
                            
                            % Fano Factor - variability compared to Poisson
                            Scores.Fano(Valve,Conc,Unit,Cycle,tset) = nanvar(TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}))./nanmean(TESTVAR{Valve,Conc,Unit,Cycle}(TrialSets{tset}));
                        end
                    end
                end
            end
        end
    end
end
%only save SCO file if all trials are requested
%     if nargin<2
%         save(SCOfile,'Scores','efd')
%     end
end
