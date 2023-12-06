clearvars
% close all
clc

%% Pick out files with 'kwik' in its name and put each in one cell
Catalog = 'S:\Expt_Sets\catalog\ExperimentCatalog_bhv.txt';
T = readtable(Catalog, 'Delimiter', ' ');
KWIKfiles = T.kwikfile(logical(T.include));

%%
for R = 1:length(KWIKfiles)
    KWIKfile = KWIKfiles{R};
    FilesKK = FindFilesKK(KWIKfile);
    efd = EFDmaker_Beast(KWIKfile);
    
    [a,b] = fileparts(FilesKK.AIP);
    RESPfile = [a,filesep,b,'.resp'];
    load(RESPfile,'-mat');
    Fs = 2000;
    
    for V = 1:length(efd.ValveTimes.PREXIndex)
        
        statedist.height = efd.BreathStats.BbyB.Height;
        statedist.width = efd.BreathStats.BbyB.Width;
        statedist.slope = efd.BreathStats.BbyB.Slope;
        
        
        tracewin = [-6 4];
        tracewinx = tracewin(1)+1/Fs:1/Fs:tracewin(2);
        
        tracewin_s = [tracewin(1)*Fs tracewin(2)*Fs];
        tracewin_sx = tracewin_s(1)+1:tracewin_s(2);
        
        
        brwin = 0;
        
        for B = 1:length(brwin)
            d = efd.ValveTimes.PREXIndex{V}+brwin(B);
            dd = efd.ValveTimes.FVSwitchTimesOn{V}+brwin(B);
            ddd = efd.ValveTimes.FVSwitchTimesOff{V}+brwin(B);
            d(d>length(PREX)) = [];
            dd(dd>length(PREX)) = [];
            ddd(ddd>length(PREX)) = [];
            PI = round(PREX(d)*Fs);
            
            bmatIDX = bsxfun(@plus,tracewin_sx,PI');
            bmatIDX(bmatIDX<0) = 1;
            bmatIDX(bmatIDX>length(RRR)) = length(RRR);
            
            btr{R,V,B} = (RRR(bmatIDX)-mean(RRR(bmatIDX(:))))/std(RRR(bmatIDX(:)));
            
%             relFT{R,V,B} = efd.ValveTimes.FVSwitchTimesOn{V}(PREX(efd.ValveTimes.PREXIndex{V}+brwin(B)));
%             relFToff{R,V,B} = efd.ValveTimes.FVSwitchTimesOff{V}(FT(R):LT(R)) - PREX(efd.ValveTimes.PREXIndex{V}+brwin(B));            
% %             relNextIn{R,V,B} = PREX(1+efd.ValveTimes.PREXIndex{V}(FT(R):LT(R))+brwin(B)) - PREX(efd.ValveTimes.PREXIndex{V}+brwin(B));
        end
        
    end
    
end

%% sniff histogram

for VOI = 1:length(cuedV)
    bin = efd.ValveTimes.PREXTimes{cuedV(VOI)}(29)-4:.5:efd.ValveTimes.PREXTimes{cuedV(VOI)}(29)+4;
    for ii = 1:length(bin)-1
        sniff_cued(VOI,ii) = sum(efd.PREX>bin(ii) & efd.PREX<bin(ii+1));
    end
end

a = mean(sniff_cued);
figure; bar(a*2)
ax = gca; ax.YAxis.Limits = [0 8];

%%

figure; hold on; 
subplot(2,2,1); hold on; plot(btr{1,3}(1,:))
ax = gca; ax.XAxis.Limits = [0 20000]; ax.YAxis.Limits = [-4 4]; ax.XTick = [4000 8000 12000];
subplot(2,2,2); hold on; plot(btr{1,3}(10,:))
ax = gca; ax.XAxis.Limits = [0 20000]; ax.YAxis.Limits = [-4 4]; ax.XTick = [4000 8000 12000];
subplot(2,2,3); hold on; plot(btr{1,3}(20,:))
ax = gca; ax.XAxis.Limits = [0 20000]; ax.YAxis.Limits = [-4 4]; ax.XTick = [4000 8000 12000];
subplot(2,2,4); hold on; plot(btr{1,3}(29,:))
ax = gca; ax.XAxis.Limits = [0 20000]; ax.YAxis.Limits = [-4 4]; ax.XTick = [4000 8000 12000];

%% Count number of sniffs during 4 seconds before FV inh
% 
% cuedV = [2:7];
% uncuedV = [1];
% 
% for VOI = 1:length(cuedV)
%     for t = 1:size(efd.ValveTimes.PREXTimes{VOI},2)
%         presniff_cued(VOI,t) = sum(efd.PREX<efd.ValveTimes.PREXTimes{cuedV(VOI)}(t) & efd.PREX>efd.ValveTimes.PREXTimes{cuedV(VOI)}(t)-4);
%         postsniff_cued(VOI,t) = sum(efd.PREX>efd.ValveTimes.PREXTimes{cuedV(VOI)}(t) & efd.PREX<efd.ValveTimes.PREXTimes{cuedV(VOI)}(t)+4);
%     end
% end
% 
% for VOI = 1:length(uncuedV)
%     for t = 1:size(efd.ValveTimes.PREXTimes{VOI},2)
%         presniff_uncued(VOI,t) = sum(efd.PREX<efd.ValveTimes.PREXTimes{uncuedV(VOI)}(t) & efd.PREX>efd.ValveTimes.PREXTimes{uncuedV(VOI)}(t)-4);
%         postsniff_uncued(VOI,t) = sum(efd.PREX>efd.ValveTimes.PREXTimes{uncuedV(VOI)}(t) & efd.PREX<efd.ValveTimes.PREXTimes{uncuedV(VOI)}(t)+4);        
%     end
% end
% 
% precuedMean = nanmean(presniff_cued,1);
% preUncuedMean = nanmean(presniff_uncued,1);
% postcuedMean = nanmean(postsniff_cued,1);
% postUncuedMean = nanmean(postsniff_uncued,1);
% 
% figure; 
% subplot(2,2,1); hold on;
% plot(precuedMean,'r-'); plot(preUncuedMean,'k-'); 
% ax = gca;
% ax.YAxis.Limits = [0 20];
% 
% subplot(2,2,2); hold on;
% plot(postcuedMean,'r-'); plot(postUncuedMean,'k-'); 
% ax = gca;
% ax.YAxis.Limits = [0 20];
% 
