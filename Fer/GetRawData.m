function GetRawData(FilesDir,GetN3,GetN6)


[~,~,Files,datapath] = InputHandling(FilesDir);
[NS6,NS3] = HeaderHandling(datapath,Files);


if GetN3
    
   RecordingNS3 = NS3EpochWriting(datapath,Files,NS3);
   
else RecordingNS3 = 0;
    
end

if GetN6
    
    RecordingNS6 = NS6EpochWriting(datapath,Files,NS6);
    
else RecordingNS6 = 0;
    
end

    save('Recordings.mat','RecordingNS3','RecordingNS6');

end

%%
function [Params,Chops,Files,datapath] = InputHandling(ParamFile)
        % Use some default parameters if there is not ParamFile
        if exist(ParamFile,'dir') == 7 % you got a folder instead of a file
%             fprintf('No paramfile; Using default params.')
            datapath = ParamFile;
            Params.chopstyle = 'all';
            Params.epochwindow = [];
            Params.splitwindows = [];
            Params.spliteventchan = [];
            Params.knowndeadchan = [];
        else
            % Parameters describing how the file should be processed are stored in a
            % json file. Examples files are here in the folder with this function.
            params = loadjson(ParamFile);
            Params = params.params;
            datapath = fileparts(ParamFile);
        end
        
        % Parse the parameters, setting various switches on or off for later
        % processes
        chopstylelist = {'all','epoch','split'};
        for chopstyle = 1:3
            Chops.(chopstylelist{chopstyle}) = sum(strcmp(Params.chopstyle, chopstylelist{chopstyle}));
        end
        
        % Check that a valid chopstyle has been selected
        if ~Chops.epoch && ~Chops.split && ~Chops.all
            error('Your chopstyle is wack. Put in {"all","epoch","split"} or some combo.')
        end
        
        % Find the ns6 and ns3 files in the same folder as the ParamFile
        Files.ns3 = dir([datapath,'/*.ns3']);
        Files.ns6 = dir([datapath,'/*.ns6']);
        
        % Check that there are the same number of NS3 and NS6 files in the folder
        if size(Files.ns3) ~= size(Files.ns6)
            error ('There have to be the same number of NS3 and NS6 files in your analysis folder.')
        end
        
        % Sort the NS3 and NS6 files
        Files.ns6 = sort({Files.ns6.name});
        Files.ns3 = sort({Files.ns3.name});
end

function [NS6,NS3] = HeaderHandling(datapath,Files)
        % This will check the first NS3 and NS6 files to gather some useful
        % parameters for further processing: # of channels, headerbytes,
        % and the channel where another bank starts if there is one
        
        dataHeaderBytes = 9; % headerbytes number from NPMK open* scripts
        
        % NS3 Header Handling
        
        % Get channel count for NS3
        FID = fopen([datapath,filesep,Files.ns3{1}],'r','ieee-le'); %little endian byte ordering
        fseek(FID, 8, 'bof'); % move past filetype specifying bits (M*Note: move to 8th byte for origin)
        BasicHeader = fread(FID, 306, '*uint8'); % read in the basic header 306 bytes to get HeaderBytes and ChannelCount
        NS3.ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header
        NS3.HeaderBytes = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % How many Bytes to skip before actual data starts
        
        % NS6 Header Handling
        
        % Get channel count for NS6
        FID = fopen([datapath,filesep,Files.ns6{1}],'r','ieee-le'); %little endian byte ordering
        fseek(FID, 8, 'bof'); % move past filetype specifying bits (M*Note: move to 8th byte for origin)
        BasicHeader = fread(FID, 306, '*uint8'); % read in the basic header 306 bytes to get HeaderBytes and ChannelCount
        NS6.ChannelCount = double(typecast(BasicHeader(303:306), 'uint32')); % pull ChannelCount out of the header
        NS6.HeaderBytes = double(typecast(BasicHeader(3:6), 'uint32')) + dataHeaderBytes; % How many Bytes to skip before actual data starts
        
        % Find the connector bank letters to determine which channel switches to a
        % new probe (if the data is from multiple probes).
        readSize = double(NS6.ChannelCount * 66);
        ExtendedHeader = fread(FID, readSize, '*uint8'); % connector bank info is in here
        for headerIDX = 1:NS6.ChannelCount % gathering all the A's and B's
            offset = double((headerIDX-1)*66);
            ChannelBank(headerIDX) = char(ExtendedHeader(21+offset) + ('A' - 1));
        end
        NS6.Bloc = find(ChannelBank == 'B',1); % This is the index of the first Channel on Bank B
end

function RecordingNS3 = NS3EpochWriting(datapath,Files,NS3)
        
        for filenumber = 1:length(Files.ns3)
            FID = fopen([datapath,filesep,Files.ns3{filenumber}],'r','ieee-le');
            % For NS3 files, we preserve the header of the first file to make it
            % easier to parse later.
            if filenumber == 1
                fseek(FID, 0, 'bof');
                Header = fread(FID, NS3.HeaderBytes, '*uint8');
            end
            
            RecordingVec = fread(FID,'uint16');
            RecordingNS3 = reshape(RecordingVec,...
                    [NS3.ChannelCount,length(RecordingVec)/NS3.ChannelCount]);
%             RecordingNS3 = reshape(RecordingVec,...
%                     [32,length(RecordingVec)/32]);
                               


            RecordingNS3 = RecordingNS3';
           
        end
end

 function RecordingNS6 = NS6EpochWriting(datapath,Files,NS6)
 
         for filenumber = 1:length(Files.ns6)
            
            FID = fopen([datapath,filesep,Files.ns6{filenumber}],'r','ieee-le');
            
            if filenumber == 1
                fseek(FID, 0, 'bof');
                Header = fread(FID, NS6.HeaderBytes, '*uint8');
            end
            
            RecordingVec = fread(FID,'uint16');
            RecordingNS6 = reshape(RecordingVec,...
                    [NS6.ChannelCount,length(RecordingVec)/NS6.ChannelCount]);
%             RecordingNS3 = reshape(RecordingVec,...
%                     [32,length(RecordingVec)/32]);
                               


            RecordingNS6 = RecordingNS6';
         end
 
 end



