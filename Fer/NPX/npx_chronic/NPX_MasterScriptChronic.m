%[InhTimes,PREX,POSTX,RRR,BbyB] = BoldingResp(CResp,2000,timeResp,CeventsMCCt(StMCC == -1)/2000,CeventsMCCt(StMCC == 1)/2000);
[InhTimes,PREX,POSTX,RRR,BbyB] = BoldingResp(CResp,2000,timeResp);


%%chronic large rec
% OlfacMat = c_OlfacMat(:,1:3);
% StMCC = c_StMCC;
% PREX = [];
% endtimes = [0,endtimes];
% for ii = 1:length(endtimes)-1
%     
%    idx = (1+sum(endtimes(1:ii))*60*2000):(sum(endtimes(1:ii+1))*60*2000);
%    %[~,tempprex] = BoldingResp(CResp(idx),2000,(1:length(CResp(idx))) / 2000);
%    [~,tempprex] = BoldingResp(CResp(idx),2000,timeResp(idx));
%    PREX = [PREX,tempprex+sum(endtimes(1:ii))*60];
%     
% end


%%%%%

%for NI board
%[InhTimes,PREX,POSTX,RRR,BbyB] = BoldingResp(CResp,2000,timeResp,CeventsNI/2000,CeventsNI2(2:2:end)/2000);

idx = (OM(:,6)==2 & OM(:,7)==3) | (OM(:,6)==3 & OM(:,7)==2);
%idx = OM(:,7)~=4 & OM(:,7)~=5;
%idx = OM(:,7) == 0;
%idx = true(size(OM,1),1);

%a = OM(idx,:);
FVevents = CeventsMCCt(StMCC == -1);
%FVevents = FVevents(a(:,6) == a(:,7));
%idx = (OM(:,6)==2 & OM(:,7)==2) | (OM(:,6)==3 & OM(:,7)==3);

[PREXmatFV,PREXmat1sPrior,PREXmatPreFV] = PostBold(round(PREX*2000), FVevents(idx));
%PREXmatFV = FVevents(idx);
%PREXmatFV = CeventsMCCt(StMCC == -1);
%for NI board
%[PREXmatFV,PREXmat1sPrior,PREXmatPreFV] = PostBold(PREX*2000, CeventsNI);

NPXSpikes.SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikes);
%NPXSpikes.SpikeTimes = FakeSpikes(NPXSpikes.SpikeTimes);



%PREXmatPreFV = PREXmat1sPrior; %Comment this out if you want the inh before fv opening.


plotparams.PSTH.Axes = 'on';
plotparams.PSTHparams.Axes = 'on';
plotparams.OnlyData = true;
plotparams.PSTHparams.PST = [-1,3];

% plotparams.NPXDepthIdx = [L3idx(1),L3idx(end)];
%plotparams.NPXDepthRange = [0, 2000];

%TimeInterval = PREXmatFV;
%TimeIntervalPr = PREXmatPreFV;

%IMPORTANT;
%if you use this remember to calculate a RasterPr with PREXmat1sPrior
% TimeInterval = [0 1];
% TimeIntervalPr = [0 1];





%%%%%%This depends on the structure of the experiment. Cannot be auto.

[PREXOdorTimes,Odors] = NPX_PREX2Odor(PREXmatFV,OlfacMat(idx,:),1);
%[PREXOdorTimes,Odors] = NPX_PREX2Odor(PREXmatFV(271:end,:),OlfacMat(271:end,:),1);
%[PREXOdorTimes,Odors] = NPX_PREX2Odor(CeventsMCCt(StMCC == -1),OlfacMat,1);
%[PREXOdorTimesPr] = NPX_PREX2Odor(PREXmatPreFV,OlfacMat,1);


plotparams.VOI = 1:length(Odors);



NPXSpikes.ValveTimes = NPX_GetBeastCompatValveTimes(PREXOdorTimes);
%NPXSpikes.ValveTimesPr = NPX_GetBeastCompatValveTimes(PREXOdorTimesPr);

Raster = NPX_RasterAlign(NPXSpikes.ValveTimes,NPXSpikes.SpikeTimes);
%RasterPr = VSRasterAlign_Beast(NPXSpikes.ValveTimesPr,NPXSpikes.SpikeTimes);


% [PREXOdorTimes,Odors] = NPX_PREX2Odor(PREXmatFV,OlfacMat,1,14:21);
% 
% NPXSpikes.ValveTimes = NPX_GetBeastCompatValveTimes(PREXOdorTimes);
% 
% RasterMono = VSRasterAlign_Beast(NPXSpikes.ValveTimes,NPXSpikes.SpikeTimes);



PSTHstruct = NPX_RasterPSTHPlotter(Raster,NPXSpikes.SpikeTimes,plotparams);

%NPXMCSR = NPX_GetMultiCycleSpikeRate(Raster,1:20, TimeInterval,OlfacMat);
%NPXMCSRpr = NPX_GetMultiCycleSpikeRate(RasterPr,1:20, TimeIntervalPr,OlfacMat);

%Scores = NPX_SCOmakerPreInh(NPXMCSR,NPXMCSRpr);

% eventsforresp = CeventsMCCt(1:2:end);
% PREXtimes.tsec{1} = PREX';
% PREXtimes.units{1} = 1;
% PREXtimes.depth(1) = 1;
% 
% prov = NPX_PREX2Odor(eventsforresp,OlfacMat,1);
% prov = NPX_GetBeastCompatValveTimes(prov);
% 
% RasterPREXv = VSRasterAlign_Beast(prov,PREXtimes); %valve aligned
% RasterPREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes,PREXtimes); %1st resp after valve aligned
%RasterLFP = NPX_LFPRasterAlign('structure.oebin',NPXSpikes.ValveTimes);








%%%%%%%%%ToneOdor
% plotparams.VOI = 1;
% 
% [PREXOdorTimes15,Odors15] = NPX_PREX2Odor(PREXmatFV,OlfacMat,1,15);
% [PREXOdorTimesPr15] = NPX_PREX2Odor(PREXmatPreFV,OlfacMat,1,15);
% 
% [PREXOdorTimes21,Odors21] = NPX_PREX2Odor(PREXmatFV,OlfacMat,1,21);
% [PREXOdorTimesPr21] = NPX_PREX2Odor(PREXmatPreFV,OlfacMat,1,21);
% 
% [PREXOdorTimes18,Odors18] = NPX_PREX2Odor(PREXmatFV,OlfacMat,1,18);
% [PREXOdorTimesPr18] = NPX_PREX2Odor(PREXmatPreFV,OlfacMat,1,18);
% 
% NPXSpikes.ValveTimes15 = NPX_GetBeastCompatValveTimes(PREXOdorTimes15);
% NPXSpikes.ValveTimesPr15 = NPX_GetBeastCompatValveTimes(PREXOdorTimesPr15);
% 
% NPXSpikes.ValveTimes21 = NPX_GetBeastCompatValveTimes(PREXOdorTimes21);
% NPXSpikes.ValveTimesPr21 = NPX_GetBeastCompatValveTimes(PREXOdorTimesPr21);
% 
% NPXSpikes.ValveTimes18 = NPX_GetBeastCompatValveTimes(PREXOdorTimes18);
% NPXSpikes.ValveTimesPr18 = NPX_GetBeastCompatValveTimes(PREXOdorTimesPr18);
% 
% Raster15 = VSRasterAlign_Beast(NPXSpikes.ValveTimes15,NPXSpikes.SpikeTimes);
% RasterPr15 = VSRasterAlign_Beast(NPXSpikes.ValveTimesPr15,NPXSpikes.SpikeTimes);
% PSTHstruct15 = NPX_RasterPSTHPlotter(Raster15,NPXSpikes.SpikeTimes,plotparams);
% 
% Raster21 = VSRasterAlign_Beast(NPXSpikes.ValveTimes21,NPXSpikes.SpikeTimes);
% RasterPr21 = VSRasterAlign_Beast(NPXSpikes.ValveTimesPr21,NPXSpikes.SpikeTimes);
% PSTHstruct21 = NPX_RasterPSTHPlotter(Raster21,NPXSpikes.SpikeTimes,plotparams);
% 
% Raster18 = VSRasterAlign_Beast(NPXSpikes.ValveTimes18,NPXSpikes.SpikeTimes);
% RasterPr18 = VSRasterAlign_Beast(NPXSpikes.ValveTimesPr18,NPXSpikes.SpikeTimes);
% PSTHstruct18 = NPX_RasterPSTHPlotter(Raster18,NPXSpikes.SpikeTimes,plotparams);

%NPXMCSR = NPX_GetMultiCycleSpikeRate(Raster,1:20, TimeInterval,OlfacMat);
%NPXMCSRpr = NPX_GetMultiCycleSpikeRate(RasterPr,1:20, TimeIntervalPr,OlfacMat);

%Scores = NPX_SCOmakerPreInh(NPXMCSR,NPXMCSRpr);

% eventsforresp = CeventsMCCt(StMCC == -1);
% PREXtimes.tsec{1} = PREX';
% PREXtimes.units{1} = 1;
% PREXtimes.depth(1) = 1;
% 
% prov = NPX_PREX2Odor(eventsforresp,OlfacMat,1);
% prov = NPX_GetBeastCompatValveTimes(prov);
% 
% RasterPREXv = VSRasterAlign_Beast(prov,PREXtimes); %valve aligned
% RasterPREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes,PREXtimes); %1st resp after valve aligned
% %RasterLFP = NPX_LFPRasterAlign('structure.oebin',NPXSpikes.ValveTimes);









%This is for WMorph
%OdorVec1 = [5,6,12];
%OdorVec1 = [14,18];
%OdorVec1 = [14,15,21];
%OdorVec1 = [5,9];
%IdxMorph = 271;
%IdxMorph = 181;

% OdorVec1 = [9];
% IdxMorph = 81;
% % 
% plotparams.VOI = 1:length(OdorVec1);
% 
% [PREXOdorTimes1,Odors1] = NPX_PREX2Odor(PREXmatFV,OlfacMat,1,OdorVec1);
% [PREXOdorTimes1Pr] = NPX_PREX2Odor(PREXmatPreFV,OlfacMat,1,OdorVec1);
% [PREXOdorTimes2,Odors2] = NPX_PREX2Odor(PREXmatFV(IdxMorph:end,:),OlfacMat(IdxMorph:end,:),1);
% [PREXOdorTimes2Pr] = NPX_PREX2Odor(PREXmatPreFV(IdxMorph:end,:),OlfacMat(IdxMorph:end,:),1);
% 
% NPXSpikes.ValveTimes1 = NPX_GetBeastCompatValveTimes(PREXOdorTimes1);
% NPXSpikes.ValveTimes1Pr = NPX_GetBeastCompatValveTimes(PREXOdorTimes1Pr);
% NPXSpikes.ValveTimes2 = NPX_GetBeastCompatValveTimes(PREXOdorTimes2);
% NPXSpikes.ValveTimes2Pr = NPX_GetBeastCompatValveTimes(PREXOdorTimes2Pr);
% 
% Raster1 = VSRasterAlign_Beast(NPXSpikes.ValveTimes1,NPXSpikes.SpikeTimes);
% %Raster1Pr = VSRasterAlign_Beast(NPXSpikes.ValveTimes1Pr,NPXSpikes.SpikeTimes);
% Raster2 = VSRasterAlign_Beast(NPXSpikes.ValveTimes2,NPXSpikes.SpikeTimes);
% Raster2Pr = VSRasterAlign_Beast(NPXSpikes.ValveTimes2Pr,NPXSpikes.SpikeTimes);
% 
% PSTHstruct1 = NPX_RasterPSTHPlotter(Raster1,NPXSpikes.SpikeTimes,plotparams);
% plotparams.VOI = 1:8; %%%%%%%%MODIFY!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSTHstruct2 = NPX_RasterPSTHPlotter(Raster2,NPXSpikes.SpikeTimes,plotparams);
% 
% % NPXMCSR1 = NPX_GetMultiCycleSpikeRate(Raster1,1:20, TimeInterval,OlfacMat);
% % NPXMCSRpr1 = NPX_GetMultiCycleSpikeRate(Raster1Pr,1:20, TimeIntervalPr,OlfacMat);
% % NPXMCSR2 = NPX_GetMultiCycleSpikeRate(Raster2,1:20, TimeInterval,OlfacMat);
% % NPXMCSRpr2 = NPX_GetMultiCycleSpikeRate(Raster2Pr,1:20, TimeIntervalPr,OlfacMat);
% % 
% % Scores1 = NPX_SCOmakerPreInh(NPXMCSR1,NPXMCSRpr1);
% % Scores2 = NPX_SCOmakerPreInh(NPXMCSR2,NPXMCSRpr2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% eventsforresp = CeventsMCCt(1:2:end);
% PREXtimes.tsec{1} = PREX';
% PREXtimes.units{1} = 1;
% PREXtimes.depth(1) = 1;
% 
% prov1 = NPX_PREX2Odor(eventsforresp,OlfacMat,1,OdorVec1);
% prov1 = NPX_GetBeastCompatValveTimes(prov1);
% 
% prov2 = NPX_PREX2Odor(eventsforresp(IdxMorph:end,:),OlfacMat(IdxMorph:end,:),1);
% prov2 = NPX_GetBeastCompatValveTimes(prov2);
% 
% Raster1PREXv = VSRasterAlign_Beast(prov1,PREXtimes); %valve aligned
% Raster1PREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes1,PREXtimes); %1st resp after valve aligned
% Raster2PREXv = VSRasterAlign_Beast(prov2,PREXtimes);
% Raster2PREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes2,PREXtimes);

clear OdorVec1 IdxMorph TimeInterval TimeIntervalPr eventsforresp prov1 prov2 prov tempprex

% RasterLFP2 = NPX_LFPRasterAlign('structure.oebin',NPXSpikes.ValveTimes2);
% 
% figure
% AveLFPMat = NPX_GetRasterLFPAveMat(RasterLFP2,2:8,2:2:100);
% a = smoothdata(AveLFPMat,1,'gaussian',15);
% imagesc(diff(diff(a)))
% caxis([-10,10])
% 
% figure
% imagesc(diff(diff(a)))
% caxis([-10,10])
% xlim([1250 1600])

clear a AveLFPMat









% %This is for MixOdorMix
% 
% 
% OlfacMat1 = [OlfacMat(1:40,:);OlfacMat(101:140,:)];
% OlfacMat2 = OlfacMat(41:100,:);
% 
% PREXmatFV1 = [PREXmatFV(1:40,:);PREXmatFV(101:140,:)];
% PREXmatFV2 = PREXmatFV(41:100,:);
% 
% PREXmatPreFV1 = [PREXmatPreFV(1:40,:);PREXmatPreFV(101:140,:)];
% PREXmatPreFV2 = PREXmatPreFV(41:100,:);
% 
% plotparams.VOI = 1:2;
% 
% [PREXOdorTimes1,Odors1] = NPX_PREX2Odor(PREXmatFV1,OlfacMat1,1);
% [PREXOdorTimes1Pr] = NPX_PREX2Odor(PREXmatPreFV1,OlfacMat1,1);
% [PREXOdorTimes2,Odors2] = NPX_PREX2Odor(PREXmatFV2,OlfacMat2,1);
% [PREXOdorTimes2Pr] = NPX_PREX2Odor(PREXmatPreFV2,OlfacMat2,1);
% 
% NPXSpikes.ValveTimes1 = NPX_GetBeastCompatValveTimes(PREXOdorTimes1);
% NPXSpikes.ValveTimes1Pr = NPX_GetBeastCompatValveTimes(PREXOdorTimes1Pr);
% NPXSpikes.ValveTimes2 = NPX_GetBeastCompatValveTimes(PREXOdorTimes2);
% NPXSpikes.ValveTimes2Pr = NPX_GetBeastCompatValveTimes(PREXOdorTimes2Pr);
% 
% Raster1 = VSRasterAlign_Beast(NPXSpikes.ValveTimes1,NPXSpikes.SpikeTimes);
% Raster1Pr = VSRasterAlign_Beast(NPXSpikes.ValveTimes1Pr,NPXSpikes.SpikeTimes);
% Raster2 = VSRasterAlign_Beast(NPXSpikes.ValveTimes2,NPXSpikes.SpikeTimes);
% Raster2Pr = VSRasterAlign_Beast(NPXSpikes.ValveTimes2Pr,NPXSpikes.SpikeTimes);
% 
% PSTHstruct1 = NPX_RasterPSTHPlotter(Raster1,NPXSpikes.SpikeTimes,plotparams);
% plotparams.VOI = 1:3; %%%%%%%%MODIFY!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PSTHstruct2 = NPX_RasterPSTHPlotter(Raster2,NPXSpikes.SpikeTimes,plotparams);
% 
% % NPXMCSR1 = NPX_GetMultiCycleSpikeRate(Raster1,1:20, TimeInterval,OlfacMat);
% % NPXMCSRpr1 = NPX_GetMultiCycleSpikeRate(Raster1Pr,1:20, TimeIntervalPr,OlfacMat);
% % NPXMCSR2 = NPX_GetMultiCycleSpikeRate(Raster2,1:20, TimeInterval,OlfacMat);
% % NPXMCSRpr2 = NPX_GetMultiCycleSpikeRate(Raster2Pr,1:20, TimeIntervalPr,OlfacMat);
% % 
% % Scores1 = NPX_SCOmakerPreInh(NPXMCSR1,NPXMCSRpr1);
% % Scores2 = NPX_SCOmakerPreInh(NPXMCSR2,NPXMCSRpr2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% eventsforresp = CeventsMCCt(1:2:end);
% eventsforresp1 = [eventsforresp(1:40,:);eventsforresp(101:140,:)];
% eventsforresp2 = eventsforresp(41:100,:);
% 
% PREXtimes.tsec{1} = PREX';
% PREXtimes.units{1} = 1;
% PREXtimes.depth(1) = 1;
% 
% prov1 = NPX_PREX2Odor(eventsforresp1,OlfacMat1,1);
% prov1 = NPX_GetBeastCompatValveTimes(prov1);
% 
% prov2 = NPX_PREX2Odor(eventsforresp2,OlfacMat2,1);
% prov2 = NPX_GetBeastCompatValveTimes(prov2);
% 
% Raster1PREXv = VSRasterAlign_Beast(prov1,PREXtimes); %valve aligned
% Raster1PREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes1,PREXtimes); %1st resp after valve aligned
% Raster2PREXv = VSRasterAlign_Beast(prov2,PREXtimes);
% Raster2PREXr = VSRasterAlign_Beast(NPXSpikes.ValveTimes2,PREXtimes);
% clear TimeInterval TimeIntervalPr eventsforresp eventsforresp1 eventsforresp2 prov1 prov2 prov
% clear OlfacMat1 OlfacMat2 PREXmatFV1 PREXmatFV2 PREXmatPreFV1 PREXmatPreFV2





%%%%Extra stuff%%%%
% FVON = NPX_PREX2Odor(CeventsMCCt(StMCC == -1),OlfacMat,1)./2000;
% FVOff = NPX_PREX2Odor(CeventsMCCt(StMCC == 1),OlfacMat,1)./2000;




% NPXSpikes = NPXSpikesBulb;
% Bank = 2;
% CResp = CMCCDataC{Bank}(1,:);
% CeventsMCCt = CeventsMCC(:,Bank);
% timeResp = (1:length(CResp)) / 2000;
% NPX_MasterScript
% NPX_GetPSTHpdf(Raster,NPXSpikes.SpikeTimes,'Bulb');
% FVON = (cell2mat((NPX_PREX2Odor(CeventsMCCt(StMCC == -1),OlfacMat,1))')')./2000;
% FVOff = (cell2mat((NPX_PREX2Odor(CeventsMCCt(StMCC == 1),OlfacMat,1))')')./2000;
% [RasterPh,FVphase] = NPX_RasterPhaseAlign(NPXSpikes.ValveTimes,NPXSpikes.SpikeTimes,PREX,{FVON,FVOff});
% plotparams.OnlyData = false;
% plotparams.PSTHparams.PST = [-3,9];
% plotparams.R.Shading = 'on';
% plotparams.R.FVtimes = FVphase;
% plotparams.PSTHparams.PST = [-3,9];
% plotparams.PSTHparams.KernelSize = 0.08;
% NPX_GetPSTHpdf(RasterPh,[],'PhaseBulb',plotparams);
% clear;
% load('pPCXNPX38D22.mat')
% NPXSpikes = NPXSpikespPCx;
% Bank = 1;
% CResp = CMCCDataC{Bank}(1,:);
% CeventsMCCt = CeventsMCC(:,Bank);
% timeResp = (1:length(CResp)) / 2000;
% NPX_MasterScript
% NPX_GetPSTHpdf(Raster,NPXSpikes.SpikeTimes,'pPCx');
% FVON = (cell2mat((NPX_PREX2Odor(CeventsMCCt(StMCC == -1),OlfacMat,1))')')./2000;
% FVOff = (cell2mat((NPX_PREX2Odor(CeventsMCCt(StMCC == 1),OlfacMat,1))')')./2000;
% [RasterPh,FVphase] = NPX_RasterPhaseAlign(NPXSpikes.ValveTimes,NPXSpikes.SpikeTimes,PREX,{FVON,FVOff});
% plotparams.OnlyData = false;
% plotparams.PSTHparams.PST = [-3,9];
% plotparams.R.Shading = 'on';
% plotparams.R.FVtimes = FVphase;
% plotparams.PSTHparams.PST = [-3,9];
% plotparams.PSTHparams.KernelSize = 0.08;
% NPX_GetPSTHpdf(RasterPh,[],'PhasepPCx',plotparams);