function [TypeIdx, TypeStack] = CellTyper (Catalog, Type, specialparams)
% Types allowed : Sorted, MUA

%% Read that catalog
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));
FT = T.FT(logical(T.include));
LT = T.LT(logical(T.include));

%%

switch Type
    case 'Sorted'
        % Simple case - all cells
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            TypeIdx{R,1} = cell2mat(SpikeTimes.units) ~= 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        
    case 'MUA'
        % Simple case - MUA
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            TypeIdx{R,1} = cell2mat(SpikeTimes.units) == 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        
    case 'CrossState' % remember that this is cell based so a cell could have some cross-state and some state-only responses
        Kindex = find(T.include);
        
        for k = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{k}));
            
            if strcmp(T.VOI(Kindex(k)),'A')
                VOI = [4,7,8,12,15,16];
            elseif strcmp(T.VOI(Kindex(k)),'B')
                VOI = [2,3,4,5,7,8];
            end
            
            TOI{1} = T.FTa(Kindex(k)):T.LTa(Kindex(k));
            TOI{2} = T.FTk(Kindex(k)):T.LTk(Kindex(k));
            
            for state = 1:2
                Trials = TOI{state};
                [Scores(state),~] = SCOmaker(KWIKfiles{k},{Trials});
            end
            
            Responder{1}{k} = Scores(1).AURp(VOI,:,1) < .05 & Scores(1).auROC(VOI,:,1)>.5;
            Responder{2}{k} = Scores(2).AURp(VOI,:,1) < .05 & Scores(2).auROC(VOI,:,1)>.5;
            CrossState = Responder{1}{k} & Responder{2}{k};
            TypeIdx{k,1} = cell2mat(SpikeTimes.units) ~= 0 & sum(CrossState)'>0; % cross state
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        
    case 'StateChanger'
        ChangeCrit = 4; % for rate
        %         ChangeCrit = 3; % for kappa
        
        Kindex = find(T.include);
        
        for k = 1:length(KWIKfiles)
            TOI{1} = T.FTa(Kindex(k)):T.LTa(Kindex(k));
            TOI{2} = T.FTk(Kindex(k)):T.LTk(Kindex(k));
            
            [SpikeTimes] = SpikeTimesPro(FindFilesKK(KWIKfiles{k}));
            efd = EFDmaker(KWIKfiles{k});
            
            FVall = cat(2,efd.ValveTimes.FVSwitchTimesOn{:});
            BreathStats = efd.BreathStats;
            %             SpikeTimes.tsec = SpikeTimes.tsec(2:end);
            %             SpikeTimes.stwarped = SpikeTimes.stwarped(2:end);
            
            for state = 1:2
                StateTime(1) = efd.ValveTimes.FVSwitchTimesOn{1}(TOI{state}(1));
                StateTime(2) = efd.ValveTimes.FVSwitchTimesOn{1}(TOI{state}(end));
                
                TW = StateTime;
                
                CycleEdges = 0:10:360; % plot from inhale to inhale
                
                for U = 1:length(SpikeTimes.tsec)
                    stwarped = SpikeTimes.stwarped{U}(SpikeTimes.tsec{U}>TW(1) & SpikeTimes.tsec{U}<TW(2));
                    for f = 1:length(FVall)
                        Toss = stwarped>FVall(f)-2 &  stwarped<FVall(f)+4;
                        stwarped(Toss) = [];
                    end
                    TossTime = 6*sum(FVall>TW(1) & FVall<TW(2));
                    
                    Awarp = (360*mod(stwarped,BreathStats.AvgPeriod)/BreathStats.AvgPeriod);
                    awrp{k}{U} = Awarp;
                    if ~isempty(awrp{k}{U})
                        Kappa{k}(state,U) = circ_kappa(deg2rad(awrp{k}{U}));
                        Rate{k}(state,U) = length(awrp{k}{U})/(TW(2)-TW(1)-TossTime);
                    else
                        Kappa{k}(state,U) = nan;
                        Rate{k}(state,U) = nan;
                    end
                end
            end
            
            StateVar = Rate;
            %             TypeIdx{k,1} = cell2mat(SpikeTimes.units) ~= 0 & (diff(StateVar{k}) < ChangeCrit)'; % Remove cells with much higher KX rates
            %             TypeIdx{k,2} = cell2mat(SpikeTimes.units) ~= 0 & (diff(StateVar{k}) > -ChangeCrit)'; % Remove cells with much higher awake rates
            %             TypeIdx{k,3} = cell2mat(SpikeTimes.units) ~= 0 & (abs(diff(StateVar{k})) < ChangeCrit)'; % Remove cells with big changes
            %             TypeIdx{k,4} = cell2mat(SpikeTimes.units) ~= 0; % Use all cells
            
            % Shortcut for testing
            TypeIdx{k,1} = cell2mat(SpikeTimes.units) ~= 0 & (abs(diff(StateVar{k})) < ChangeCrit)'; % Remove cells with big changes
            
            
        end
        
        %         TypeStack{1} = cat(1,TypeIdx{:,1});
        %         TypeStack{2} = cat(1,TypeIdx{:,2});
        %         TypeStack{3} = cat(1,TypeIdx{:,3});
        %         TypeStack{4} = cat(1,TypeIdx{:,4});
        
        % Shortcut for testing
        TypeStack{1} = cat(1,TypeIdx{:,1});
        
    case 'OnOff'
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            
            [Scores,~] = SCOmaker(KWIKfiles{R},{FT(R):LT((R))});
            AR = Scores.auROC(specialparams.VOI,:,1);
            AP = Scores.AURp(specialparams.VOI,:,1);
            UP = AR>.5 & AP<.05;
            DN = AR<.5 & AP<.05;
            
            uppers = (sum(DN)==0 & sum(UP)>0);
            downers = (sum(DN)>0 & sum(UP)==0);
            valences{R} = uppers - downers;
            TypeIdx{R,1} = (valences{R}>0)' & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,2} = (valences{R}<0)' & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,3} = cell2mat(SpikeTimes.units) ~= 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        TypeStack{3} = cat(1,TypeIdx{:,3});
        
    case 'Laser'
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesKK(FindFilesKK(KWIKfiles{R}));
            efd(R) = EFDmaker(KWIKfiles{R});
            % label laser responsive cells
            for unit = 1:size(efd(R).LaserSpikes.SpikesBeforeLaser,2)
                Control = efd(R).LaserSpikes.SpikesBeforeLaser{unit};
                Stimulus = efd(R).LaserSpikes.SpikesDuringLaser{unit};
                [auROC, p] = RankSumROC(Control, Stimulus);
                LR{R}(unit) = auROC>.7 & p<.05;
            end
            TypeIdx{R,1} = LR{R}' & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,2} = ~LR{R}' & cell2mat(SpikeTimes.units) ~= 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        
    case 'LaserDepth'
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            WV.ypos{R} = WaveStats(SpikeTimes.Wave);
            WV.ypos{R} = [nan; WV.ypos{R}];
            
            efd(R) = EFDmaker(KWIKfiles{R});
            % label laser responsive cells
            for unit = 1:size(efd(R).LaserSpikes.SpikesBeforeLaser,2)
                Control = efd(R).LaserSpikes.SpikesBeforeLaser{unit};
                Stimulus = efd(R).LaserSpikes.SpikesDuringLaser{unit};
                [auROC, p] = RankSumROC(Control, Stimulus);
                LR{R}(unit) = auROC>.7 & p<.05;
            end
            TypeIdx{R,1} = LR{R}' & WV.ypos{R}<-70 & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,2} = LR{R}' & WV.ypos{R}>0 & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,3} = ~LR{R}' & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,4} = ~LR{R}' & WV.ypos{R}<0 & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,5} = ~LR{R}' & WV.ypos{R}>0 & cell2mat(SpikeTimes.units) ~= 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        TypeStack{3} = cat(1,TypeIdx{:,3});
        TypeStack{4} = cat(1,TypeIdx{:,4});
        TypeStack{5} = cat(1,TypeIdx{:,5});
        
    case 'Depth'
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            WV.ypos{R} = WaveStats(SpikeTimes.Wave);
            WV.ypos{R} = [nan; WV.ypos{R}];
            
            TypeIdx{R,1} = WV.ypos{R}<-50 & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,2} = WV.ypos{R}>50 & cell2mat(SpikeTimes.units) ~= 0;
            TypeIdx{R,3} = cell2mat(SpikeTimes.units) ~= 0;
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        TypeStack{3} = cat(1,TypeIdx{:,3});
        
    case 'WaveAndRate'
        for R = 1:length(KWIKfiles)
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            [~,WV.pttime{R}] = WaveStats(SpikeTimes.Wave);
            overall_rates{R} = cellfun(@length,SpikeTimes.tsec(2:end))/max(SpikeTimes.tsec{1});
            
            TypeIdx{R,1} = [0; (WV.pttime{R} > 0.4 & overall_rates{R} < 6)];
            TypeIdx{R,2} = [0; (WV.pttime{R} < 0.4 & overall_rates{R} > 6)];
            TypeIdx{R,3} = [0; (overall_rates{R} > 6)];
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        TypeStack{3} = cat(1,TypeIdx{:,3});
        
    case 'BHV'
        for R = 1:length(KWIKfiles)
            % behavior params
            [a,b] = fileparts(KWIKfiles{R});
            D = dir(fullfile(a,'\bhv\*.bh_prm'));
            [Y,I] = sort([D.datenum]);
            paramfile = D(I(end)).name;
            load(fullfile(a,'\bhv\',paramfile),'-mat');
            VOI = [params.RewardedChannel params.odorchannels(~ismember(params.odorchannels,params.RewardedChannel))];
            
            % trial outcomes
            clear TC
            [~, outcomes] = multiblock_outcomes (KWIKfiles{R});
            for od = VOI
                TC{od} = outcomes.TrialCodes(outcomes.odor == od);
                if isfield(specialparams,'Trials')
                    TC{od} = TC{od}(specialparams.Trials{R});
                end
            end
            
            [efd] = EFDmaker(KWIKfiles{R},'bhv');
            for U = 1:size(efd.ValveSpikes.MultiCycleSpikeRate,2)
                % dependent variable
                if strcmp(specialparams.DV,'cycle')
                    DV = cell2mat(efd.ValveSpikes.MultiCycleSpikeRate(VOI,U,1)');
                elseif strcmp(specialparams.DV,'odor')
                    DV = cell2mat(efd.ValveSpikes.SpikesDuringOdor(VOI,U,1)');
                end
                DV(isnan(DV)) = [];
                if isfield(specialparams,'Trials')
                    DV = reshape(DV,2,[])';
                    DV = DV(specialparams.Trials{R},:);
                    DV = DV';
                    DV = DV(:);
                end
                
                
                % independent variable
                IV = cell2mat(TC);
                F1 = double(IV>3);
                F2 = double(ismember(IV,[1,6]));
                S = ones(size(IV));
                FACTNAMES = {'rewarded odor', 'licked'};
                
                % anova
                [p,tbl,stats] = anovan(DV,{F1,F2},'model','interaction','display','off');
                TypeIdx{R,1}(U,1) = tbl{2,end}<.05 & U> 1;
                TypeIdx{R,2}(U,1) = tbl{3,end}<.05 & U > 1;
                TypeIdx{R,3}(U,1) = tbl{4,end}<.05 & U > 1;
            end
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        TypeStack{2} = cat(1,TypeIdx{:,2});
        TypeStack{3} = cat(1,TypeIdx{:,3});
        
    case 'Stable'
        for R = 1:length(KWIKfiles)
            clear OR
            % Stable units
            FilesKK = FindFilesKK(KWIKfiles{R});
            
            [a,b] = fileparts(FilesKK.KWIK);
            if length(strfind(FilesKK.KWIK,'.'))<2
                WFfile = [a,filesep,b,'.wf'];
            else
                WFfile = [a,filesep,b(1:strfind(b,'.')),'wf'];
            end
            
            if  exist(WFfile,'file')
                load(WFfile,'-mat');
            end
            
            TypeIdx{R,1} = logical([0; (~(10.^abs(log10(OR(1,:)./OR(2,:))) > specialparams.DFRlim | abs(min(OR)) < specialparams.FRlim | abs(diff(maxAmp)) > specialparams.UVlim*4))']);
        end
        TypeStack{1} = cat(1,TypeIdx{:,1});
        
    case 'StableDepth'
        for R = 1:length(KWIKfiles)
            % stable part
             clear OR
            % Stable units
            FilesKK = FindFilesKK(KWIKfiles{R});
            
            [a,b] = fileparts(FilesKK.KWIK);
            if length(strfind(FilesKK.KWIK,'.'))<2
                WFfile = [a,filesep,b,'.wf'];
            else
                WFfile = [a,filesep,b(1:strfind(b,'.')),'wf'];
            end
            
            if  exist(WFfile,'file')
                load(WFfile,'-mat');
            end
            
            stable{R,1} = logical([0; (~(10.^abs(log10(OR(1,:)./OR(2,:))) > specialparams.DFRlim | abs(min(OR)) < specialparams.FRlim | abs(diff(maxAmp)) > specialparams.UVlim*4))']);
     
            % depth part
            SpikeTimes = SpikeTimesPro(FindFilesKK(KWIKfiles{R}));
            WV.ypos{R} = WaveStats(SpikeTimes.Wave);
            WV.ypos{R} = [nan; WV.ypos{R}];
            
            A = [-200:40:120];
            B = [-120:40:200];
            
            for pp = 1:length(A)
                TypeIdx{R,pp} = WV.ypos{R}>A(pp) & WV.ypos{R}<B(pp) & cell2mat(SpikeTimes.units) ~= 0 & stable{R,1};
            end
%             TypeIdx{R,1} = WV.ypos{R}<20 & cell2mat(SpikeTimes.units) ~= 0 & stable{R,1};
%             TypeIdx{R,2} = WV.ypos{R}>20 & cell2mat(SpikeTimes.units) ~= 0 & stable{R,1};
%             TypeIdx{R,3} = cell2mat(SpikeTimes.units) ~= 0 & stable{R,1};
        end
        for pp = 1:length(A)
            TypeStack{pp} = cat(1,TypeIdx{:,pp});
        end
%         TypeStack{1} = cat(1,TypeIdx{:,1});
%         TypeStack{2} = cat(1,TypeIdx{:,2});
%         TypeStack{3} = cat(1,TypeIdx{:,3});
end
end
