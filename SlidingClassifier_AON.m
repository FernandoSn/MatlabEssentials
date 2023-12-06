clearvars
% close all
clc

%% Pick out recording files and put each in one cell
% ROI = {'AON'};
% Catalog = 'Z:\AON\Expt_Sets\catalog\ExperimentCatalog_AON';

ROI = {'PCX'};
Catalog = 'Y:\public\BR_Microscope\ExperimentCatalog_PCX';

T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include) & strcmp(T.ROI,ROI));

%% Identify LR and nonLR cells
for R = 1:length(KWIKfiles)
    LR{R} = LRcellFinalizer(KWIKfiles{R});
end

for R = 1:length(KWIKfiles)
    SpikeTimes = SpikeTimes_Beast(FindFilesKK(KWIKfiles{R}));
    TypeIdx{R,1} = ismember(1:length(SpikeTimes.units),LR{R}.primLR)';
    TypeIdx{R,2} = ismember(1:length(SpikeTimes.units),[LR{R}.nonLR,LR{R}.secLR])';
end

TypeStack{1} = cat(1,TypeIdx{:,1});
TypeStack{2} = cat(1,TypeIdx{:,2});

%% Windowmaking
BinSize = .03;
PST = [0 1.5];
WindowType = 'Expanding';

% StepSize = BinSize/2;
% windowend = PST(1):StepSize:PST(2);%.5-BinSize/2; % sliding window
% win_t = windowend+BinSize/2;

windowend = (PST(1)+BinSize):BinSize:PST(2); % expanding window
win_t = windowend-BinSize/2;

%% Decoding separate experiments
% for k = 1:length(KWIKfiles)
%     [a,b] = fileparts(KWIKfiles{k});
%     D = dir(fullfile(a,'\bhv\*.bh_prm'));
%     [~,I] = sort([D.datenum]);
%     paramfile = D(I(end)).name;
%     load(fullfile(a,'\bhv\',paramfile),'-mat');
%
%     % map odor channels to efd entries
%     [Y,VOI] = sort(params.odorchannels);
%     VOI = VOI(2:end);
%     COI = 1:length(params.odorconc);
%
%     efd(k) = EFDmaker(KWIKfiles{k});
%
Trials = 1:15;
%
%     for cty = 1:size(TypeStack,2)
%         for w = 1:length(windowend)
%             % X{k} = all trials of odor 1 followed by all trials of odor 2 X number of cells
%             % Y here is odor labels.
%             Raster = efd(k).ValveSpikes.RasterAlign(VOI,2,TypeIdx{k,cty});
%             [Y,X{k},n_bins{k}] = BinRearranger(Raster,[0 BinSize]+windowend(w),BinSize,Trials);
%
%             % odor discrimination
%             task{1}.taskstim{1} = unique(Y);
%             [~,ACC{k,cty}(w), ~] = GenTaskClassifier(Y, X{k}, task{1});
%         end
%     end
% end

% appet = [2,5];
% avers = [8,9];


%% Decoding pseudopopulation across experiments
for w = 1:length(windowend)
    for k = 1:length(KWIKfiles)
        if k == 1
            [a,b] = fileparts(KWIKfiles{k});
            D = dir(fullfile(a,'\bhv\*.bh_prm'));
            [~,I] = sort([D.datenum]);
            paramfile = D(I(end)).name;
            load(fullfile(a,'\bhv\',paramfile),'-mat');
            
            % map odor channels to efd entries
            [Y,VOI] = sort(params.odorchannels);
            VOI = VOI(2:end);
            COI = 1:length(params.odorconc);
        end
        efd(k) = EFDmaker(KWIKfiles{k});
        % X{k} = all trials of odor 1 followed by all trials of odor 2 X number of cells
        % Y here is odor labels.
        Raster = efd(k).ValveSpikes.RasterAlign(VOI,3,:);
%         [Y,X{k},n_bins{k}] = BinRearranger(Raster,[0 BinSize]+windowend(w),BinSize,Trials); %sliding
        [Y,X{k},n_bins{k}] = BinRearranger(Raster,[0 windowend(w)],BinSize,Trials); %expanding
    end
    
%     Y(ismember(Y,appet)) = 100;
%     Y(ismember(Y,avers)) = 200;
%     Y(Y<100) = 300;
      innate = [2,5,8,9];
      Y(ismember(Y,innate)) = [];
    
    for cty = 1:size(TypeStack,2)
        for iter = 1:200
            XX = cell2mat(X);
            
            randset = randperm(sum(TypeStack{cty}),150); %min(cellfun(@sum,TypeStack)));
            cellset = find(TypeStack{cty});
            
            % odor discrimination
            task{1}.taskstim{1} = unique(Y);
            [~,ACCpp{cty}(w,iter), ~] = GenTaskClassifier(Y, XX(:,cellset(randset)), task{1});
        end
    end
end



%%
% figure(1)
% clf
% printpos([400 400 1000 300])
% colores = [.6 .7 .2; 0 0 0];
% for k = 1:length(KWIKfiles)
%     subplot(1,length(KWIKfiles),k)
%     for cty = 1:size(TypeStack,2)
%         plot(win_t,ACC{k,cty},'color',colores(cty,:))
%         hold on
%         box off; ylim([0 1]); xlim(PST);
%         axis square;
%     end
% end
%

%%
figure
clf
printpos([100 400 300 300])
colores = [.6 .7 .2; 0 0 0];

for cty = 1:size(TypeStack,2)
    plot(win_t,mean(ACCpp{cty},2),'color',colores(cty,:),'LineWidth',1.5)
    hold on;
    box off; ylim([0 1]); xlim(PST);
    axis square;
end
%
% %%
% for k = 1:length(KWIKfiles)
%
%     for d = 1:size(ACC,2)
%         [p,L(k,d)] = max(ACC{k,d});
%         L(k,d) = win_t(L(k,d));
%
%     end
% end