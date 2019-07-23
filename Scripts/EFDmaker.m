function [efd] = EFDmaker(KWIKfile, varargin)
%%function [efd] = EFDmaker(KWIKfile)

[a,b] = fileparts(KWIKfile);
if length(strfind(KWIKfile,'.'))<2
    EFDfile = [a,filesep,b,'.efd'];
else
    EFDfile = [a,filesep,b(1:strfind(b,'.')),'efd'];
end

if isempty(varargin)
    if ~(exist([a,filesep,'bhv'],'dir'))
        CA = 'old';
    elseif (exist([a,filesep,'bhv'],'dir'))
        CA = 'bhv';
    end
elseif strcmp(varargin{1},'bhv') || exist([a,filesep,'bhv'],'dir')
    CA = 'bhv';
elseif strcmp(varargin{1},'remake')
    CA = 'rmk';
end

switch CA
    % if isempty(varargin) && ~(exist([a,filesep,'bhv'],'dir'))
    case 'old'
        if ~(exist(EFDfile,'file'))
            [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
            
            %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
            [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
            efd.PREX = PREX;
            
            save(EFDfile,'efd')
        else
            load(EFDfile,'-mat')
        end
    case 'rmk'
        disp('remaking')
        [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
        
        %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
        [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
        efd.PREX = PREX;
        
        save(EFDfile,'efd')
        
    case 'bhv'
        
        if exist(EFDfile,'file')
            load(EFDfile,'-mat')
        else
            CSVs = dir([a,filesep,'bhv\*.csv']);
            T = readtable([a,filesep,'bhv',filesep,CSVs(1).name], 'Delimiter', ',', 'HeaderLines', 1);
            if size(T,2) <= 4 % non-Beast file
                [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
                [efd] = bhv_combiner(KWIKfile,efd);
                
                %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
                [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
                efd.PREX = PREX;
                
                save(EFDfile,'efd')
            else % Beast file - not fully converted because I still use SpikeTimesPro
%                 [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1_Beast(KWIKfile);
                [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1(KWIKfile);
                [efd] = bhv_combiner_beast(KWIKfile,efd);
                
                
                %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
                [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker_Beast(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
                efd.PREX = PREX;
                
                save(EFDfile,'efd')
            end
        end
end
