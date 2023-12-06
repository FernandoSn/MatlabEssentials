function [Params,Files,NS6] = PrePro( ParamFile )
%PrePro - Read a ParamFile and reference, chop and/or concatenate, and create LFP files for
%files in same folder as ParamFile
%   The ParamFile (someparams.json) has to be in the same folder with
%   relevant *.ns3 and *.ns6 files.
%   If there are multiple *.ns6 and *.ns3 files, they will automatically
%   be concatenated in order based on the last number in their filename.
%   FKA PrePro_SC_edit2
% Collect Params from json file, Determine chopstyle, Collect names of
% all ns6 and ns3 files in the analysis folder
[Params,Chops,Files,datapath] = InputHandling(ParamFile);

% TODO: If there are events find the beginning of the event windows and store
% them in a variable called EventBytes
% Collect event information for epochs and splits
if Chops.epoch || Chops.split
    if length(Files.ns3)>1
        error('Cannot split on multiple files for now.')
    end
    openNSx([datapath,filesep,Files.ns3{1}]);
    eventdata = double(NS3.Data(Params.spliteventchan,:));
    
    % find upward going mean crossings (i.e. on times)
    eventdata = eventdata-max(eventdata)/2;
    SignSwitch = eventdata(1:end-1).*eventdata(2:end);
    dED = diff(eventdata);
    EventTimesAll = find(dED>0 & SignSwitch<0)/2000;
    for S = 1:size(Params.splitwindows,1)
        SplitStart{S} = EventTimesAll(max(1,Params.splitwindows(S,1)-1));
        SplitEnd{S} = EventTimesAll(min(length(EventTimesAll),Params.splitwindows(S,2)+1));
        if  Params.splitwindows(S,1) == 1
            SplitStart{S}(1) = 0;
        end
        if  Params.splitwindows(S,2) == length(EventTimesAll)
            SplitEnd{S} = length(eventdata)/2000;
        end
    end
end

% Collect ChannelCounts, HeaderBytes, and location of first channel of
% second bank.
[NS6,NS3] = HeaderHandling(datapath,Files);

% Make a folder to stash processed epochs in
if ~exist([datapath,'/epochs'],'dir')
    mkdir(datapath,'epochs');
end

% Write NS3 epochs. Here we are looping through all of the NS3 files.
% For only the first file (filenumber == 1), scrape off the header and save
% it as 'epochs/NS3.header'.
[headerfname] = NS3EpochWriting(datapath,Files,NS3);

% Write NS6 epochs
[NumBanks] = NS6EpochWriting(datapath,Files,NS6,Params);

%% Concatenate NS3 epochs
if Chops.all
    [~, fname] = fileparts(Files.ns3{1});
    finalfilename = [datapath,filesep,'epochs',filesep,fname,'.ns3'];
    D = dir([datapath,'\epochs\*3ep*']);
    [CatList,~] = sort({D.name}); % output of dir command is not guaranteed to be sorted but concatenation has to happen in order
    for ep = 1:length(CatList)
        if ep == 1
            CatCmd3 = ['copy /b ' headerfname '+' [datapath,filesep,'epochs',filesep,CatList{ep}] ,' ',finalfilename];
            system(CatCmd3);
        else
            CatCmd3 = ['copy /b ' finalfilename '+' [datapath,filesep,'epochs',filesep,CatList{ep}], ' ', finalfilename];
            system(CatCmd3);
        end
    end
    system(['del ',datapath,'\epochs\*3ep*'])
    system(['del ',datapath,'\epochs\*header*'])

elseif Chops.split

    [~, fname] = fileparts(Files.ns3{1});
    for S = 1:size(Params.splitwindows,1)
        finalfilename = [datapath,filesep,'epochs',filesep,fname,'split',num2str(S,'%02.0f'),'.ns3'];
        D = dir([datapath,'\epochs\split',num2str(S,'%02.0f'),'*3ep*']);
        [CatList,~] = sort({D.name}); % output of dir command is not guaranteed to be sorted but concatenation has to happen in order
        for ep = 1:length(CatList)
            if ep == 1
                CatCmd3 = ['copy /b ' headerfname '+' [datapath,filesep,'epochs',filesep,CatList{ep}] ,' ',finalfilename];
                system(CatCmd3);
            else
                CatCmd3 = ['copy /b ' finalfilename '+' [datapath,filesep,'epochs',filesep,CatList{ep}], ' ', finalfilename];
                system(CatCmd3);
            end
        end
    end
    system(['del ',datapath,'\epochs\*3ep*'])
    system(['del ',datapath,'\epochs\*header*'])
end

%
%% Concatenate NS6 epochs
if Chops.all
    [~, fname] = fileparts(Files.ns6{1});
    for Bank = 1:NumBanks
        finalfilename = [datapath,filesep,'epochs',filesep,fname,'_bank',num2str(Bank),'.dat'];
        D = dir([datapath,'\epochs\*6ep*bank',num2str(Bank)]);
        [CatList,~] = sort({D.name}); % output of dir command is not guaranteed to be sorted but concatenation has to happen in order
        for ep = 1:length(CatList)
            if ep == 1
                CatCmd6 = ['copy /b ' [datapath,filesep,'epochs',filesep,CatList{ep}] ,' ',finalfilename];
                system(CatCmd6);
            else
                CatCmd6 = ['copy /b ' finalfilename '+' [datapath,filesep,'epochs',filesep,CatList{ep}], ' ', finalfilename];
                system(CatCmd6);
            end
        end
    end
    system(['del ',datapath,'\epochs\*6ep*'])
elseif Chops.split
    [~, fname] = fileparts(Files.ns6{1});
    for Bank = 1:NumBanks
        for S = 1:size(Params.splitwindows,1)
            finalfilename = [datapath,filesep,'epochs',filesep,fname,'split',num2str(S,'%02.0f'),'_bank',num2str(Bank),'.dat'];
            D = dir([datapath,'\epochs\split',num2str(S,'%02.0f'),'*6ep*bank',num2str(Bank)]);
            [CatList,~] = sort({D.name}); % output of dir command is not guaranteed to be sorted but concatenation has to happen in order
            for ep = 1:length(CatList)
                if ep == 1
                    CatCmd6 = ['copy /b ' [datapath,filesep,'epochs',filesep,CatList{ep}] ,' ',finalfilename];
                    system(CatCmd6);
                else
                    CatCmd6 = ['copy /b ' finalfilename '+' [datapath,filesep,'epochs',filesep,CatList{ep}], ' ', finalfilename];
                    system(CatCmd6);
                end
            end
        end
    end
    system(['del ',datapath,'\epochs\*6ep*'])
end
%%

% Nested Functions
    function [Params,Chops,Files,datapath] = InputHandling(ParamFile)
        % Use some default parameters if there is not ParamFile
        if exist(ParamFile,'dir') == 7 % you got a folder instead of a file
            fprintf('No paramfile; Using default params.')
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
    function [headerfname] = NS3EpochWriting(datapath,Files,NS3)
        
        for filenumber = 1:length(Files.ns3)
            FID = fopen([datapath,filesep,Files.ns3{filenumber}],'r','ieee-le');
            % For NS3 files, we preserve the header of the first file to make it
            % easier to parse later.
            if filenumber == 1
                fseek(FID, 0, 'bof');
                Header = fread(FID, NS3.HeaderBytes, '*uint8');
                headerfname = [datapath,filesep,'epochs\NS3.header'];
                % Opening the output file for saving
                FIDw = fopen(headerfname, 'w+', 'ieee-le');
                fwrite(FIDw, Header, 'uint8');
                fclose(FIDw);
            end
            
            % If chopstyle is 'all', work in 5 minute epochs. Otherwise use
            % Params.epochwindow.
            
            % How many epochs do we need?
            fseek(FID, 0, 'eof'); % move to the end of the file
            DataBytes = double(ftell(FID))-NS3.HeaderBytes; % measure how long the data is IN BYTES
            DataSamplesTotal = DataBytes/2; % If there are 100 Bytes of data there are 50 samples
            
            % Read Size
            NS3.Fs = 2000; % Sampling frequency for NS3 files
            EpochSeconds = 300;
            % EpochSamples is not in Bytes. To turn this into Bytes multiply by 2.
            EpochSamples = NS3.ChannelCount*EpochSeconds*NS3.Fs;
            EpochBytes = EpochSamples*2;
            
            % Find the byte you should seek to when reading the next epoch.
            if Chops.all
                EpochStarts = NS3.HeaderBytes + 0:EpochBytes:DataBytes;
                
                % Write epochs to new files with a naming scheme that can be sorted
                for ep = 1:length(EpochStarts)
                    % Read in an epoch's worth of samples
                    fseek(FID,EpochStarts(ep),'bof');
                    if ep < length(EpochStarts) % If we have not yet reached the last epoch
                        Epoch = fread(FID, EpochSamples, '*int16');
                    else
                        Epoch = fread(FID, inf, '*int16'); % For the last epoch read to the end.
                    end
                    
                    % Write to a new file ('filenumber01.3ep001')
                    newfname3 = [datapath '\epochs\filenumber',num2str(filenumber,'%02.0f'),'.3ep',num2str(ep,'%03.0f')];
                    FIDw = fopen(newfname3, 'w+', 'ieee-le');
                    fwrite(FIDw, Epoch, 'int16');
                    fclose(FIDw);
                end % end of looping through epochs
                fclose(FID);
                
            elseif Chops.split
                 for S = 1:size(Params.splitwindows,1)
                    SplitStartSample = round(NS3.ChannelCount*SplitStart{S}*NS3.Fs);
                    SplitStartBytes = SplitStartSample*2;
                    SplitEndSample = round(NS3.ChannelCount*SplitEnd{S}*NS3.Fs);
                    SplitEndBytes = SplitEndSample*2;
                    
                    % Write epochs to new files with a naming scheme that can be sorted
                    EpochStarts = NS3.HeaderBytes + SplitStartBytes:EpochBytes:SplitEndBytes;
                    
                    % Write epochs to new files with a naming scheme that can be sorted
                    for ep = 1:length(EpochStarts)
                        % Read in an epoch's worth of samples
                        fseek(FID,EpochStarts(ep),'bof');
                        if ep < length(EpochStarts) % If we have not yet reached the last epoch
                            Epoch = fread(FID, EpochSamples, '*int16');
                        else
                            LastReadSamples = SplitEndSample - round((EpochStarts(end)-NS6.HeaderBytes)/2);
                            Epoch = fread(FID, LastReadSamples, '*int16'); % For the last epoch read to the end.
                        end
                       % Write to a new file ('filenumber01.3ep001')
                        newfname3 = [datapath '\epochs\split',num2str(S,'%02.0f'),'filenumber',num2str(filenumber,'%02.0f'),'.3ep',num2str(ep,'%03.0f')];
                        FIDw = fopen(newfname3, 'w+', 'ieee-le');
                        fwrite(FIDw, Epoch, 'int16');
                        fclose(FIDw);
                    end % end of looping through epochs
                end % end of looping through splits
                fclose(FID);
            end % end of chops if statement
        end % end of looping through files
    end

    function [NumBanks] = NS6EpochWriting(datapath,Files,NS6,Params)
        % Check for more than one bank. If NS6.Bloc is empty there is one bank [~isempty == 0]. If
        % it is not empty there are two banks [~isempty == 1].
        NumBanks = ~isempty(NS6.Bloc)+1;
        if NumBanks > 1
            BankChannels{1} = 1:NS6.Bloc-1;
            BankChannels{2} = NS6.Bloc:NS6.ChannelCount;
        else
            BankChannels{1} = 1:NS6.ChannelCount;
        end
        
        for filenumber = 1:length(Files.ns6)
            
            FID = fopen([datapath,filesep,Files.ns6{filenumber}],'r','ieee-le');
            
            % If chopstyle is 'all', work in 5 minute epochs. Otherwise use
            % Params.epochwindow.
            
            % How many epochs do we need?
            fseek(FID, 0, 'eof'); % move to the end of the file
            DataBytes = double(ftell(FID))-NS6.HeaderBytes; % measure how long the data is IN BYTES
            DataSamplesTotal = DataBytes/2; % If there are 100 Bytes of data there are 50 samples
            
            % Read Size
            NS6.Fs = 30000; % Sampling frequency for NS3 files
            EpochSeconds = 300;
            % EpochSamples is not in Bytes. To turn this into Bytes multiply by 2.
            EpochSamples = NS6.ChannelCount*EpochSeconds*NS6.Fs;
            EpochBytes = EpochSamples*2;
            
            % Find the byte you should seek to when reading the next epoch.
            if Chops.all
                EpochStarts = NS6.HeaderBytes + 0:EpochBytes:DataBytes;
                
                % Write epochs to new files with a naming scheme that can be sorted
                for ep = 1:length(EpochStarts)
                    % Read in an epoch's worth of samples
                    fseek(FID,EpochStarts(ep),'bof');
                    if ep < length(EpochStarts) % If we have not yet reached the last epoch
                        Epoch = fread(FID, EpochSamples, '*int16');
                    else
                        Epoch = fread(FID, inf, '*int16'); % For the last epoch read to the end.
                    end
                    % Take the linearized data stream and reshape into a matrix with
                    % channels as rows;
                    Epoch = reshape(Epoch,[NS6.ChannelCount length(Epoch)/NS6.ChannelCount]); % to get back to linearized just use (:) on a matrix this shape
                    
                    
                    % Write to a new file ('filenumber01.6ep001_bank1')
                    for Bank = 1:NumBanks
                        [SplitEpochs{Bank}] = Epoch(BankChannels{Bank},:);
                        SplitEpochs{Bank} = SplitEpochs{Bank}(:);
                        newfname6 = [datapath '\epochs\filenumber',num2str(filenumber,'%02.0f'),'.6ep',num2str(ep,'%03.0f'),'_bank',num2str(Bank)];
                        FIDw = fopen(newfname6, 'w+', 'ieee-le');
                        fwrite(FIDw, SplitEpochs{Bank}, 'int16');
                        fclose(FIDw);
                    end
                    
                end % end of looping through epochs
                
                fclose(FID);
                
            elseif Chops.split
                for S = 1:size(Params.splitwindows,1)
                    SplitStartSample = round(NS6.ChannelCount*SplitStart{S}*NS6.Fs);
                    SplitStartBytes = SplitStartSample*2;
                    SplitEndSample = round(NS6.ChannelCount*SplitEnd{S}*NS6.Fs);
                    SplitEndBytes = SplitEndSample*2;
                    
                    % Write epochs to new files with a naming scheme that can be sorted
                    EpochStarts = NS6.HeaderBytes + SplitStartBytes:EpochBytes:SplitEndBytes;
                    
                    % Write epochs to new files with a naming scheme that can be sorted
                    for ep = 1:length(EpochStarts)
                        % Read in an epoch's worth of samples
                        fseek(FID,EpochStarts(ep),'bof');
                        if ep < length(EpochStarts) % If we have not yet reached the last epoch
                            Epoch = fread(FID, EpochSamples, '*int16');
                        else
                            LastReadSamples = SplitEndSample - round((EpochStarts(end)-NS6.HeaderBytes)/2);
                            Epoch = fread(FID, LastReadSamples, '*int16'); % For the last epoch read to the end.
                        end
                        % Take the linearized data stream and reshape into a matrix with
                        % channels as rows;
                        Epoch = reshape(Epoch,[NS6.ChannelCount length(Epoch)/NS6.ChannelCount]); % to get back to linearized just use (:) on a matrix this shape
                        
                        
                        
                        % Write to a new file ('filenumber01.6ep001_bank1')
                        for Bank = 1:NumBanks
                            [SplitEpochs{Bank}] = Epoch(BankChannels{Bank},:);
                            SplitEpochs{Bank} = SplitEpochs{Bank}(:);
                            newfname6 = [datapath '\epochs\split',num2str(S,'%02.0f'),'filenumber',num2str(filenumber,'%02.0f'),'.6ep',num2str(ep,'%03.0f'),'_bank',num2str(Bank)];
                            FIDw = fopen(newfname6, 'w+', 'ieee-le');
                            fwrite(FIDw, SplitEpochs{Bank}, 'int16');
                            fclose(FIDw);
                        end
                        
                    end % end of looping through epochs
                end % end of looping through splits
                fclose(FID);
            end % end of chops if statement
        end % end of looping through files
    end
end