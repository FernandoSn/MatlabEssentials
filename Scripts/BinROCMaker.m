function [bROC, bROCp] = BinROCMaker(KWIKfile, PST, BinSize, varargin)
%%function [bROC, bROCp] = BinROCMsaker(KWIKfile, PST, BinSize, ControlValve, Trials)
%
%Inputs:
%KWIKfile - path to KWIK file path
%PST - range of plots [time(sec) before inhalation, time(sec) after
%inhalation] Ex: [-0.5 1]
%BinSize - size of bin in seconds
%ControlValve (default 1) - Ex: [1 9]
%Trials (default all trials) - Ex: [1 3 7]

    efd=EFDmaker(KWIKfile);
    Raster=efd.ValveSpikes.RasterAlign;
    %default control valve
    if isempty(varargin{1})
        ControlValve=1;
    else
        ControlValve=varargin{1};
    end
    
    if isempty(varargin{2})
        Trials = 1:length(efd.ValveSpikes.RasterAlign{ControlValve,1});
    else
        Trials = varargin{2};
    end
        
    [~, blankPSTHtrials, ~] = PSTHmaker(Raster(ControlValve,:), PST, BinSize, Trials);
    
    for V = 1:size(Raster,1)
        %default trials of all trials
        if isempty(varargin{2})
            Trials=1:length(efd.ValveSpikes.RasterAlign{V,1});
        end
        [~, PSTHtrials, PSTHt] = PSTHmaker(Raster(V,:), PST, BinSize, Trials);
        ControlBins = reshape(cat(1,blankPSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        StimulusBins = reshape(cat(1,PSTHtrials{:}),size(PSTHtrials,2),[],length(PSTHt));
        for unit = 1:size(ControlBins,1) % unit
            for bin = 1:size(ControlBins,3) % bin
                [bROC(V,unit,bin),bROCp(V,unit,bin)] = RankSumROC(ControlBins(unit,:,bin),StimulusBins(unit,:,bin));
            end
        end
        
    end
