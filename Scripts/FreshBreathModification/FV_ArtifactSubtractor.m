% FV_ArtifactSubtractor

% [asRESP] = FV_ArtifactRemover(FVOpens,FVCloses,RESP,Fs,t)

FVOpens = sort(cell2mat(efd.ValveTimes.FVSwitchTimesOn));
FVCloses = sort(cell2mat(efd.ValveTimes.FVSwitchTimesOff));

timewin = -.5*Fs:.5*Fs;

FVOwin = bsxfun(@plus,ceil(FVOpens*Fs),timewin');
FVCwin = bsxfun(@plus,ceil(FVCloses*Fs),timewin');

Oresp  = handles.resp(FVOwin);
Cresp  = handles.resp(FVCwin);

dOresp = mean(diff(Oresp),2);
dCresp = mean(diff(Cresp),2);

Othr = prctile(abs(dOresp),99);
Cthr = prctile(abs(dOresp),99);

artstartO = find(timewin(1:end-1)'>0 & abs(dOresp)>Othr,1);
artendO = find(abs(dOresp(artstartO:end)) < Othr,1)+artstartO;

artstartC = find(timewin(1:end-1)'>0 & abs(dCresp)>Cthr,1);
artendC = find(smooth(abs(dCresp(artstartC:end)),21) < Cthr,1)+artstartC;