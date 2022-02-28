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
        
        
    elseif contains(fnames{ii},'Neuropix')
        
        cd([EventsDir,'\',fnames{ii}])
        tempF = dir;
        tempF = {tempF.name};
        cd([EventsDir,'\',fnames{ii},'\',tempF{end}])
        
        tempeve = double(readNPY('timestamps.npy'));
        tempbool = tempeve>1;  
        eventsNPX = [eventsNPX,tempeve(tempbool)];
                
        tempst = double(readNPY('channel_states.npy'));
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



CeventsMCC = zeros(size(eventsMCC,1),Banks);
CMCCDataC = cell(1,2);

for bank = 1:Banks
       
%     [tempevents,tempdata] = NPX_SynchStreams(eventsMCC, eventsNPX(:,bank), MCCData);
%     [tempevents,tempdata] = NPX_SynchStreams(eventsMCC(StMCC==-1 | StMCC==1),...
%         eventsNPX(StNPX(:,bank)==-1 | StNPX(:,bank)==1,bank), MCCData);
    [tempevents,tempdata] = NPX_SynchStreams(eventsMCC, eventsNPX(:,bank), StMCC, StNPX(:,bank), MCCData);
    
    CeventsMCC(:,bank) = tempevents;
    CMCCDataC{bank} = tempdata;
      
end

cd(MainDir)
cd('..')

save(FileName,'CeventsMCC','CMCCDataC','eventsMCC','eventsNPX','MCCData',...
    'OlfacMat','OM','StMCC','StNPX');