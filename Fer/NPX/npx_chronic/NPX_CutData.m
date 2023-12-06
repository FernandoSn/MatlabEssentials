function NPX_CutData(filename, endtime)

%endtime is in minutes.

Fs = 2000;
endsample = round(endtime*Fs*60);

load(filename);


%fileLength = size(CMCCDataC{1},2);

for ii = 1:length(CMCCDataC)
   
    if ~isempty(CMCCDataC{ii})
       
        CMCCDataC{ii} = CMCCDataC{ii}(:,1:endsample);
        
    end
    
end


FVclose = CeventsMCC(StMCC == 1);
FVclose = FVclose(FVclose<(endsample-Fs*3));
StimNo = sum(OM(:,1) == 1);
FVclose = FVclose(1:end-mod(length(FVclose),StimNo));

OM = OM(1:length(FVclose),:);
OlfacMat = OlfacMat(1:length(FVclose),:);

idx = find(FVclose(end) == CeventsMCC);

if ( (length(StMCC)>idx) && (StMCC(idx+1) == -2) )
    CeventsMCC = CeventsMCC(1:idx+2);
else
    CeventsMCC = CeventsMCC(1:idx);
end
StMCC = StMCC(1:length(CeventsMCC));

eventsNPX = eventsNPX(1:length(FVclose)*2);
StNPX = StNPX(1:length(eventsNPX));

save(['c_',filename],'CeventsMCC','CMCCDataC','eventsNPX',...
    'OlfacMat','OM','StMCC','StNPX','endtime');