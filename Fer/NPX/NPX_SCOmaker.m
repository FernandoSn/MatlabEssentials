function Scores = NPX_SCOmaker(NPXMCSR)

%This function is based on SCOmaker_Beast and uses the same statistics to
%compare blank vs valves.

%NPXMCSR = Neuropixels MultiCycleSpikeRate obtained from
%GetNPXMultiCycleSpikeRate.

if nargin < 2
    TrialSets{1} = 1:length(NPXMCSR{1});
end

%% Here we will take any measure of the response and give indications of
% how different the odorant response is from valve 1.
% These will include: auROC, p-value for ranksum test, z-score, rate
% change, mean and SD of valve 1 response.

%% Cycles
%TESTVAR = efd.ValveSpikes.MultiCycleSpikeRate(:,:,:,:);
%     TESTVAR_select = (TESTVAR(5:12,2:size(TESTVAR,2),:));


for tset = 1:length(TrialSets)
    if ~isempty(TrialSets{tset})
        for Unit = 1:size(NPXMCSR,2)
            % Blank Rate and SD
            Scores.BlankRate(Unit,tset) = nanmean(NPXMCSR{1,Unit}(TrialSets{tset}));
            Scores.BlankSD(Unit,tset) = nanstd(NPXMCSR{1,Unit}(TrialSets{tset}));
            for Valve = 1:size(NPXMCSR,1)   
                % First Cycle
                % auROC and p-value for ranksum test
                [Scores.auROC(Valve,Unit,tset), Scores.AURp(Valve,Unit,tset)] = RankSumROC(NPXMCSR{1,Unit}(TrialSets{tset}),NPXMCSR{Valve,Unit}(TrialSets{tset}));

                % Z-Scores based on valve 1 responses vs everything else.
                Scores.ZScore(Valve,Unit,tset) = (nanmean(NPXMCSR{Valve,Unit}(TrialSets{tset}))-nanmean(NPXMCSR{1,Unit}(TrialSets{tset})))./nanstd(NPXMCSR{1,Unit}(TrialSets{tset}));
                Scores.ZScore(isinf(Scores.ZScore)) = NaN;

                % Rate change based on valve 1 responses vs everything else. The
                % denominator comes into play here.
                Scores.RateChange(Valve,Unit,tset) = (nanmean(NPXMCSR{Valve,Unit}(TrialSets{tset}))-nanmean(NPXMCSR{1,Unit}(TrialSets{tset})));

                % Raw Rate
                Scores.RawRate(Valve,Unit,tset) = nanmean(NPXMCSR{Valve,Unit}(TrialSets{tset}));

                % Fano Factor - variability compared to Poisson
                Scores.Fano(Valve,Unit,tset) = nanvar(NPXMCSR{Valve,Unit}(TrialSets{tset}))./nanmean(NPXMCSR{Valve,Unit}(TrialSets{tset}));           
            end          
        end
    end
end
%only save SCO file if all trials are requested
%     if nargin<2
%         save(SCOfile,'Scores','efd')
%     end
end
