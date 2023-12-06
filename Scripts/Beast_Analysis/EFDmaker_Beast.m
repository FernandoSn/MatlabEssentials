function [efd] = EFDmaker_Beast(KWIKfile, varargin)
%%function [efd] = EFDmaker(KWIKfile)

[a,b] = fileparts(KWIKfile);
if length(strfind(KWIKfile,'.'))<2
    EFDfile = [a,filesep,b,'.efd'];
else
    EFDfile = [a,filesep,b(1:strfind(b,'.')),'efd'];
end

if isempty(varargin)
    if ~(exist(EFDfile,'file'))
        [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1_Beast(KWIKfile);
        
        %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
        [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker_Beast(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
        efd.PREX = PREX;
        
        save(EFDfile,'efd')
    else
        load(EFDfile,'-mat')
    end
    
elseif strcmp(varargin{1},'remake')
    [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1_Beast(KWIKfile);
    
    %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
    [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker_Beast(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
    efd.PREX = PREX;
    
    save(EFDfile,'efd')
    
elseif strcmp(varargin{1},'bhv') || exist([a,filesep,'bhv'],'dir')
    if ~(exist(EFDfile,'file'))
        [efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX,Fs,t,efd.BreathStats] = GatherInfo1_Beast(KWIKfile);
        [efd] = bhv_combiner_beast(KWIKfile,efd);
        
        
        %% Here we are gathering information. Creating histograms, some spike counts, and statistics based on histograms.
        [efd.ValveSpikes,efd.LaserSpikes,efd.LVSpikes] = VSmaker_Beast(efd.ValveTimes,efd.LaserTimes,efd.LVTimes,SpikeTimes,PREX);
        efd.PREX = PREX;
        
        save(EFDfile,'efd')
    else
        load(EFDfile,'-mat')
    end
    
end