function [bROC, bROCp] = BinROCPlotter(KWIKfile, PST, BinSize, varargin)
%%function [bROC, bROCp] = BinROCPlotter(KWIKfile, PST, BinSize, ControlValve, Trials)
%
%Inputs:
%KWIKfile - path to KWIK file path
%PST - range of plots [time(sec) before inhalation, time(sec) after
%inhalation] Ex: [-0.5 1]
%BinSize - size of bin in seconds
%ControlValve (default 1) - Ex: [1 9]
%Trials (default all trials) - Ex: [1 3 7]

[bROC, bROCp] = BinROCmaker(KWIKfile, PST, BinSize, varargin);
imagesc(squeeze(bROC(5,2:end,:)))
colormap(redbluecmap(64))
caxis([0 1])

