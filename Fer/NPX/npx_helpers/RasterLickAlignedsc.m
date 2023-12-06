lasttrial = 324;
Bank = 1;

CeventsMCCt = CeventsMCC(StMCC == -1,Bank);

LicksRight = NPX_GetLicks(CMCCDataC{Bank}(6,1:CeventsMCCt(lasttrial+1)));
LicksLeft = NPX_GetLicks(CMCCDataC{Bank}(7,1:CeventsMCCt(lasttrial+1)));
% LicksRight = NPX_GetLicks(CMCCDataC{Bank}(6,:));
% LicksLeft = NPX_GetLicks(CMCCDataC{Bank}(7,:));


Licks = sort([LicksRight;LicksLeft]);
%Licks = LicksLeft;

% CResp = CMCCDataC{Bank}(1,1:CeventsMCCt(lasttrial+1));
% timeResp = (1:length(CResp)) / 2000;
% [~,Licks] = BoldingResp(CResp,2000,timeResp);
% Licks = round(Licks*2000);

RL = NPX_GetLickAlignedRaster(Licks,CeventsMCCt(1:lasttrial),NPXSpikeslpPCx,OlfacMat(1:lasttrial,:));


% Licks = {NPX_GetLicks(CMCCDataC{Bank}(7,1:CeventsMCCt(lasttrial+1)))};
% RAllLicksL = NPX_RasterAlign(NPX_GetBeastCompatValveTimes(Licks),NPXSpikes.SpikeTimes);