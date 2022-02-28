function Recording = importMCCbin(FileName, Channels)

s=dir(FileName);
fileID = fopen(FileName);

%Recording = fread(fileID,[Channels , s.bytes / 2 / Channels],'uint16');
%Recording = fread(fileID,[Channels , s.bytes / 8 / Channels],'double');
Recording = fread(fileID,[Channels , s.bytes / 4 / Channels],'float');

Recording = double(Recording);

fclose(fileID);