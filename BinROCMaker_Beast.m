function [bROC, bROCp] = BinROCMaker_Beast(Raster, PST, BinSize, varargin)
%%function [bROC, bROCp] = BinROCMsaker(KWIKfile, PST, BinSize, ControlValve, Trials)
%
%Inputs:
%KWIKfile - path to KWIK file path
%PST - range of plots [time(sec) before inhalation, time(sec) after
%inhalation] Ex: [-0.5 1]
%BinSize - size of bin in seconds
%ControlValve (default 1) - Ex: [1 9]
%Trials (default all trials) - Ex: [1 3 7]

%     efd=EFDmaker_Beast(KWIKfile);
%     Raster=efd.ValveSpikes.RasterAlign;
    %default control valve
    if isempty(varargin)
        ControlValve = 1;
        ControlConc = 1;
    else
        ControlValve = varargin{1};
        ControlConc = varargin{2};
    end
    
    if isempty(varargin)
        Trials = 1:length(Raster{ControlValve,ControlConc,1});
    else
        Trials = varargin{2};
    end
        
    [~, blankPSTHtrials, ~] = PSTHmaker_Beast(Raster(ControlValve,ControlConc,:), PST, BinSize, Trials);
    ControlBins = cellcat3d(squeeze(blankPSTHtrials));
    
    for V = 1:size(Raster,1)
        for C = 1:size(Raster,2)
            %default trials of all trials
%             if isempty(varargin)
%                 Trials=1:length(Raster{V,1});
%             end
            [~, PSTHtrials, PSTHt] = PSTHmaker_Beast(Raster(V,C,:), PST, BinSize, Trials);
            StimulusBins = cellcat3d(squeeze(PSTHtrials));

            for unit = 1:size(ControlBins,1) % unit
                for bin = 1:size(ControlBins,3) % bin
                    [bROC(V,C,unit,bin),bROCp(V,C,unit,bin)] = RankSumROC(ControlBins(unit,:,bin),StimulusBins(unit,:,bin));
                end
            end
        end
    end
