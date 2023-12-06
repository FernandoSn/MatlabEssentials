
lasttrial = 534;
% lasttrial = 426;
Bank = 1;
delay = 1*2000;
GoodTrials = false(size(OM,1),1);

if Bank == 1
    NPXSpikes.SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikesrpPCx);
elseif Bank == 2
    NPXSpikes.SpikeTimes = NPX_GetBeastCompatSpikeTimes(NPXSpikeslpPCx);
end

CeventsMCCt = CeventsMCC(StMCC == -1,Bank);

if lasttrial == size(OM,1)
    
    [~,PREX] = BoldingResp(CMCCDataC{Bank}(1,:),2000,(1:length(CMCCDataC{Bank}(1,:))) / 2000);
    LicksRight = NPX_GetLicks(CMCCDataC{Bank}(6,:));
    LicksLeft = NPX_GetLicks(CMCCDataC{Bank}(7,:));

else
    [~,PREX] = BoldingResp(CMCCDataC{Bank}(1,1:CeventsMCCt(lasttrial+1)),2000,(1:length(CMCCDataC{Bank}(1,1:CeventsMCCt(lasttrial+1)))) / 2000);
    LicksRight = NPX_GetLicks(CMCCDataC{Bank}(6,1:CeventsMCCt(lasttrial+1)));
    LicksLeft = NPX_GetLicks(CMCCDataC{Bank}(7,1:CeventsMCCt(lasttrial+1)));
end


Licks = sort([LicksRight;LicksLeft]);

CeventsMCCt = CeventsMCCt(1:lasttrial);
[PREXmatFV,~,~] = PostBold(round(PREX*2000), CeventsMCCt);
PREXmatFV = PREXmatFV(:,1);

a = OlfacMat(1:lasttrial,:);
PREXmatFV = PREXmatFV(1:lasttrial);
b = OM(1:lasttrial,:);


ag = a(:,3)~=0;
a = a(ag,:);
PREXmatFV = PREXmatFV(ag);
b = b(ag,:);
GoodTrials(1:lasttrial) = ag;
gidcs = find(ag);




GT = false(length(PREXmatFV),1);
D = zeros(length(PREXmatFV),1);
n = 1;

for ii = 1:length(GoodTrials)
    
   if GoodTrials(ii) 
       idx = find(Licks > PREXmatFV(n),1); 
       D(n) = Licks(idx) - PREXmatFV(n);
       if (D(n) > delay) && (idx==1 || abs(PREXmatFV(n) - Licks(idx-1)) > 2000)

           GT(n) = true;
           GoodTrials(ii) = true;
       else
          GoodTrials(ii) = false; 
       end
       n = n+1;
   end
   
end

PREXmatFV = PREXmatFV(GT);
a = a(GT,:);
b = b(GT,:);

PREXOdorTimes = NPX_PREX2Odor(PREXmatFV,a,1);

ValveTimes = NPX_GetBeastCompatValveTimes(PREXOdorTimes);

Raster = NPX_RasterAlign(ValveTimes,NPXSpikes.SpikeTimes);


% [~,sidx] = sortrows(OlfacMat,[2,1]);
% GoodTrials = GoodTrials(sidx);



