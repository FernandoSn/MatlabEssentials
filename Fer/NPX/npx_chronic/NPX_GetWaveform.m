function wfs = NPX_GetWaveform(NPXSpikes,unit,chanNo,filename)


samples = 100;
chans = 16;
ss = NPXSpikes.ss(NPXSpikes.clu == unit);
chan = round(NPXSpikes.CluDepth(NPXSpikes.cids == unit)/10);
chanRange = (chan - chans/2)+1 : chan + chans/2;
if chanRange(1)<1; chanRange = chanRange+chanRange(1)+1;end
%wfs = zeros(length(ss),chans,samples);
wfs = cell(1,length(ss));

fid = fopen(filename, 'r');


for ii = 1:length(ss)
   
    fseek(fid,(ss(ii)-samples/2) * chanNo * 2,'bof');
    dat = fread(fid, [chanNo,samples], '*int16');
    %wfs(ii,:,:) = dat(chanRange,:);
    wfs{ii} = dat(chanRange,:);
    %wfs{ii} = dat;
    
end