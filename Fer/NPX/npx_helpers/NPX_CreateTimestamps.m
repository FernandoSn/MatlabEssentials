function ts = NPX_CreateTimestamps(DataFileName, channels)

%Helper function to create the timestamps.npy file required for Kilosort.

%This file is automatically created by Open Ephys, this function is useful
%if the file was deleted and you need it back.


%DataFileName = Name or path of the continous.dat file that is associated
%with the timestamps.npy file

if nargin < 2
   
    
    channels = 384; %Neuropixels default
    
end

s = dir(DataFileName);         
filesize = s.bytes;

StampsNo = filesize ./ channels ./ 2; %2 because data are int16

ts = int64(1:StampsNo)';

writeNPY(ts, 'NEWtimestamps.npy');

