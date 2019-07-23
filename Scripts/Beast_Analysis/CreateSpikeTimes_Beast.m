function [SpikeTimes] = CreateSpikeTimes_Beast(FilesKK,Fs,tWarpLinear,SpikeType)
% 
% if nargin < 4 || strcmp(SpikeType,'Good')
%     [a,b] = fileparts(FilesKK.KWIK);
%     STfile = [a,filesep,b,'.st'];
% else
%     [a,b] = fileparts(FilesKK.KWIK);
%     STfile = [a,filesep,b,'-',SpikeType,'.st'];
% end

if nargin<4
    SpikeType = 'Good';
end

% if it's the default don't add anything to the filename.
% if it's something special add that title to the filename
if strcmp(SpikeType,'Good')
    [a,b] = fileparts(FilesKK.KWIK);
    if length(strfind(FilesKK.KWIK,'.'))<2
        STfile = [a,filesep,b,'.st'];
    else
        STfile = [a,filesep,b(1:strfind(b,'.')),'st'];
    end
else
    [a,b] = fileparts(FilesKK.KWIK);
    STfile = [a,filesep,b,'-',SpikeType,'.st'];
end

[SpikeTimes] = SpikeTimes_Beast(FilesKK,SpikeType);
% 
% % Retrieve SpikeTimes from cluster file
% if nargin<4
%     if length(strfind(FilesKK.KWIK,'.'))<2
%         [SpikeTimes] = SpikeTimesKK(FilesKK);
%     else
%         [SpikeTimes] = SpikeTimesSpykingCircus(FilesKK);
%     end
% else
%     [SpikeTimes] = SpikeTimesKK(FilesKK,SpikeType);
% end

if ~isfield(SpikeTimes,'stwarped')
    % Warp SpikeTimes by tWarp
    SpikeTimes.stwarped = cell(length(SpikeTimes.tsec),1);
    
    for i = 1:length(SpikeTimes.tsec)
        x = round(SpikeTimes.tsec{i}.*Fs);
        x = x(x>0 & x<length(tWarpLinear));
        SpikeTimes.stwarped{i} = tWarpLinear(x)';
    end
    
    save(STfile,'SpikeTimes','-v7.3')
end

end