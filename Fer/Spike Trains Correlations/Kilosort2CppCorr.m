function Spikes = Kilosort2CppCorr(s,filename)

%%Takes the struct returned by loadKSdirGoodUnits (modified function
%%of the Spikes Steinmetz library for handling phy2 output).

%%Formats the data in the same way of Bolding's functions to handle
%%blackrock data. This is useful because SpikeTrainAnalysis in C++ only
%%takes data formatted in that way.

NoUnits = size(s.cids,2);

sscarray = cell(NoUnits,1);

for ii = 1:NoUnits
    
    sscarray{ii} = uint32(s.ss(s.clu == s.cids(ii)));
%     Spikes.cids(ii) = s.cids(ii);
    
end
Spikes.cids = s.cids;
Spikes.tsec = sscarray;

SpikesRef = Spikes;
SpikesTar = Spikes;

%Write File with samples instead of spike times.

archivos=dir;

for aa=1:size(archivos,1)
    if strcmp(archivos(aa).name,[filename,'.dat'])
        error('Archivo existente, selecciona otro nombre');
    end
end

% if isempty(efd)
    Valves = 1;%Actually valves can be the number of different stimuli presented.
    Concentrations = 1; %provisional
    Trials = 1;
    UnitsRef = size(SpikesRef.tsec,1) - 1;
    UnitsTar = size(SpikesTar.tsec,1) - 1;
% else
%     Valves = size(efd.ValveTimes.FVSwitchTimesOn,1);%Actually valves can be the number of different stimuli presented.
%     Concentrations = 1; %provisional
%     Trials = size(efd.ValveTimes.FVSwitchTimesOn{1},2);
%     UnitsRef = size(SpikesRef.tsec,1) - 1;
%     UnitsTar = size(SpikesTar.tsec,1) - 1;
% end

fid = fopen([filename,'.dat'],'w+');

if(fid==0); error('unable to open file');end

fwrite(fid,Valves,'uint16');
fwrite(fid,Concentrations,'uint16');
fwrite(fid,Trials,'uint16');
fwrite(fid,UnitsRef,'uint16');
fwrite(fid,UnitsTar,'uint16');

for ii = 2:UnitsRef+1
    fwrite(fid,size(SpikesRef.tsec{ii},1),'uint32');
end

for ii = 2:UnitsTar+1
    fwrite(fid,size(SpikesTar.tsec{ii},1),'uint32');
end

for ii = 2:UnitsRef+1
    fwrite(fid,SpikesRef.tsec{ii},'uint32');
end

for ii = 2:UnitsTar+1
    fwrite(fid,SpikesTar.tsec{ii},'uint32');
end

fclose(fid);

% if isempty(efd)
%     fclose(fid);
%     return;
% end


% for ii = 1:Valves
%     fwrite(fid,efd.ValveTimes.FVSwitchTimesOn{ii},'uint32');
% end
% 
% for ii = 1:Valves
%     fwrite(fid,efd.ValveTimes.FVSwitchTimesOff{ii},'uint32');
% end
% 
% for ii = 1:Valves
%     fwrite(fid,efd.ValveTimes.PREXTimes{ii},'uint32');
% end

% fclose(fid);