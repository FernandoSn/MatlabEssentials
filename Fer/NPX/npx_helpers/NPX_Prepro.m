function NPX_Prepro(FileName,MainDir)


%For this to work folder arrangement should be Open Ephys binary.
%and the olfactometer file should be in MainDir.

Banks = 0;
RecordingDir = [MainDir,'\experiment1\recording1'];
EventsDir = [RecordingDir,'\events'];

cd(MainDir)

fnames = dir;
fnames = {fnames.name};

for ii = 1:length(fnames)
   
    %if contains(fnames{ii},'Olfactometer')
    if contains(fnames{ii},'Olfac')
       
        OM = importdata(fnames{ii});
        if any(isnan(OM(end,:)))
            OM = OM(1:end-1,:);
        end
        
        if size(OM,2) == 3
            
            OlfacMat = OM;
            
        elseif size(OM,2) == 6
            OlfacMat = round([OM(:,1),sum(OM(:,2:3) .* (OM(:,4:5)./255),2),ones(size(OM,1),1)]);
            OlfacMat(:,2) = sum((OM(:,2:3) .* OM(:,4:5))./max(sum(OM(:,4:5),2)),2);
        
        elseif size(OM,2) == 7
             OlfacMat = OM(:,[1,2,7]); 
             OlfacMat(:,2) = sum((OM(:,2:3) .* OM(:,4:5))./max(sum(OM(:,4:5),2)),2);
        end
        
        break
    end
    
end

cd(EventsDir)

fnames = dir;
fnames = {fnames.name};

eventsNPX = []; %binary events
StNPX = []; %Channel states

for ii = 1:length(fnames)
   
    if contains(fnames{ii},'MCDAQ')
       
        cd([EventsDir,'\',fnames{ii}])
        tempF = dir;
        tempF = {tempF.name};
        cd([EventsDir,'\',fnames{ii},'\',tempF{end}])
        
        eventsMCC = double(readNPY('timestamps.npy'));
        tempbool = eventsMCC>1; 
        eventsMCC = eventsMCC(tempbool);
        StMCC = double(readNPY('channel_states.npy'));
        StMCC = StMCC(tempbool);
        
%         eventsMCC = eventsMCC(StMCC == 1 | StMCC == -1);
%         StMCC = StMCC(StMCC == 1 | StMCC == -1);
        
        
    elseif contains(fnames{ii},'Neuropix')
        
        cd([EventsDir,'\',fnames{ii}])
        tempF = dir;
        tempF = {tempF.name};
        cd([EventsDir,'\',fnames{ii},'\',tempF{end}])
        
        tempeve = double(readNPY('timestamps.npy'));
        %tempeve = [tempeve(1:956);tempeve(959:end)];

        tempbool = tempeve>1;  
        eventsNPX = [eventsNPX,tempeve(tempbool)];
                
        tempst = double(readNPY('channel_states.npy'));
        %tempst = [tempst(1:956);tempst(959:end)];
        
        StNPX = [StNPX,tempst(tempbool)];
        Banks = Banks +1;
        
        
    end
    
end

cd(RecordingDir)

MCCData = load_open_ephys_binary('structure.oebin', 'continuous',Banks*2 +1);

MCCData = [MCCData.Data(10,:);MCCData.Data(11,:);... %Resp;PID
    MCCData.Data(1,:);MCCData.Data(2,:);MCCData.Data(3,:);... %Ball axes
    MCCData.Data(8,:);MCCData.Data(16,:)]; %Right lick,Left lick

%seems that PID is 11 and not 16
%lick right channel 8
%lick left channel 16


%correcting additional trials when optotagging and olfactometer is still
%running. For this to work you must delete the extra trials manually from
%the olfactometer txt file.
% 
idx = find(StMCC == 1);
idx = idx(1:size(OlfacMat,1));
tempeve = eventsMCC(idx(end)+1:end,:);
tempSt = StMCC(idx(end)+1:end,:);

tempeve = tempeve(tempSt ~= -1 & tempSt ~= 1);
tempSt = tempSt(tempSt ~= -1 & tempSt ~= 1);

eventsMCC = [eventsMCC(1:idx(end),:);tempeve];
StMCC = [StMCC(1:idx(end),:);tempSt];

% % % eventsMCC = eventsMCC(1:idx(end),:);
% % % StMCC = StMCC(1:idx(end),:);
%%%%%%%%%%%%%%%%%


CeventsMCC = zeros(size(eventsMCC,1),Banks);
CMCCDataC = cell(1,2);

for bank = 1:Banks
       
%     [tempevents,tempdata] = NPX_SynchStreams(eventsMCC, eventsNPX(:,bank), MCCData);
%     [tempevents,tempdata] = NPX_SynchStreams(eventsMCC(StMCC==-1 | StMCC==1),...
%         eventsNPX(StNPX(:,bank)==-1 | StNPX(:,bank)==1,bank), MCCData);

    if size(eventsNPX,1) > size(eventsMCC,1)
        [tempevents,tempdata] = NPX_SynchStreams(eventsMCC, eventsNPX(1:size(eventsMCC,1),bank), StMCC, StNPX(1:size(StMCC,1),bank), MCCData);
    else
        [tempevents,tempdata] = NPX_SynchStreams(eventsMCC, eventsNPX(:,bank), StMCC, StNPX(:,bank), MCCData);
    end
    
    CeventsMCC(:,bank) = tempevents;
    CMCCDataC{bank} = tempdata;
      
end

cd(MainDir)
cd('..')

save(FileName,'CeventsMCC','CMCCDataC','eventsMCC','eventsNPX','MCCData',...
    'OlfacMat','OM','StMCC','StNPX');