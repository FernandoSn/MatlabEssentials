function [SpikeTimes] = SpikeTimesSpykingCircus(FilesKK)
% SpikeTimesKK will return a structure called SpikeTimes with tsec, chans, and
% units. SpikeTimes{1} is the sum of all sorted Units.

[hpath,hfile] = fileparts(FilesKK.KWIK);
STfile = [hpath,filesep,hfile(1:strfind(hfile,'.')),'st'];

if exist(STfile,'file')
    loadhelper.b = load(STfile,'-mat');
    SpikeTimes = loadhelper.b.SpikeTimes;
else
    
    a = h5info([hpath,filesep,hfile,'.hdf5'],'/spiketimes');
    b = {a.Datasets.Name};
    
    for unit = 1:length(b)
        Units{unit+1} = str2num(b{unit}(findstr('_',b{unit})+1:end));
        TSECS{unit+1} = h5read([hpath,filesep,hfile,'.hdf5'],['/spiketimes/',b{unit}])/30000;
        TSECS{unit+1} = TSECS{unit+1}(:);
    end
    TSECS{1} = cell2mat(TSECS');
    Units{1} = 1000;
    
    SpikeTimes.tsec = TSECS';
    SpikeTimes.units = Units';
end

%%
save(STfile,'SpikeTimes','-v7.3')
end





