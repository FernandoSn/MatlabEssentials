function NPX_RemoveLightArtifacts(Events)

% CAUTION: Make a copy of your raw file first!!
% 
% This function should be called in the recording dir.
% 
% Remove light artifacts of an opto experiment

Raw = load_open_ephys_binary('structure.oebin', 'continuous', 1,'mmap');


RemMed = false;

MedWnd = 60;
%DelWnd = [-1 , 8];
DelWnd = [-35 , 100];
DelSam = numel(DelWnd(1):DelWnd(2));

MedArtOn = zeros(size(Raw.Data.Data.mapped,1),MedWnd);
MedArtOff = zeros(size(Raw.Data.Data.mapped,1),MedWnd);

TempMatOn = zeros(length(Events)/2,MedWnd);
TempMatOff = zeros(length(Events)/2,MedWnd);

EventsOn = Events(1:2:end);
EventsOff = Events(2:2:end);

if RemMed
for ch = 1:size(Raw.Data.Data.mapped,1)
   
    for event = 1:length(EventsOn)
        
        TempMatOn(event,:) = Raw.Data.Data(1).mapped(ch,EventsOn(event):EventsOn(event)+(MedWnd-1));
        TempMatOff(event,:) = Raw.Data.Data(1).mapped(ch,EventsOff(event):EventsOff(event)+(MedWnd-1));
        
    end
    
    MedArtOn(ch,:) = median(TempMatOn);
    MedArtOff(ch,:) = median(TempMatOff);
    
    fprintf(1, 'median ch %d\n', ch);
    
end
end

Raw.Data.Writable = true;

for event = 1:length(EventsOn)
    
    
    if RemMed
        Raw.Data.Data(1).mapped(:,EventsOn(event):EventsOn(event)+(MedWnd-1)) =...
            Raw.Data.Data(1).mapped(:,EventsOn(event):EventsOn(event)+(MedWnd-1)) -...
            int16(MedArtOn);
    end
%     Raw.Data.Data(1).mapped(:,EventsOn(event):EventsOn(event)+8) =...
%         int16(repmat(median(Raw.Data.Data(1).mapped(:,EventsOn(event)-200:EventsOn(event)-100),2),[1,9]));

    Raw.Data.Data(1).mapped(:,EventsOn(event)+DelWnd(1):EventsOn(event)+DelWnd(2)) =...
        int16(repmat(median(Raw.Data.Data(1).mapped(:,EventsOn(event)-200:EventsOn(event)-100),2),[1,DelSam]));
    
    
    if RemMed
        Raw.Data.Data(1).mapped(:,EventsOff(event):EventsOff(event)+(MedWnd-1)) =...
            Raw.Data.Data(1).mapped(:,EventsOff(event):EventsOff(event)+(MedWnd-1)) -...
            int16(MedArtOff);
    end
%     Raw.Data.Data(1).mapped(:,EventsOff(event)-1:EventsOff(event)+8) =...
%         int16(repmat(median(Raw.Data.Data(1).mapped(:,EventsOff(event)-200:EventsOff(event)-100),2),[1,10]));

    Raw.Data.Data(1).mapped(:,EventsOff(event)+DelWnd(1):EventsOff(event)+DelWnd(2)) =...
        int16(repmat(median(Raw.Data.Data(1).mapped(:,EventsOff(event)-200:EventsOff(event)-100),2),[1,DelSam]));


    
    fprintf(1, 'event corrected %d\n', event);
    
end
