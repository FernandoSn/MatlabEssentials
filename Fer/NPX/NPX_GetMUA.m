function MUASpikeTimes = NPX_GetMUA(filename, nChansTotal,thresh)
% Subtracts median of each channel, then subtracts median of each time
% point.
%
% filename should include the extension
% outputDir is optional, by default will write to the directory of the input file
%
% should make chunk size as big as possible so that the medians of the
% channels differ little from chunk to chunk.

if nargin < 3
    
    thresh = 6;
end
chunkSize = 1000000;
COI = 100;

[b,a] = butter(4,[300 6000]./(30000/2),'bandpass');
Fs = 30000;
%MinDist = 0.001 * Fs;

d = dir(filename);
nSampsTotal = d.bytes/nChansTotal/2;
nChunksTotal = ceil(nSampsTotal/chunkSize);

MUASpikeTimes.tsec = cell(COI,1);
MUASpikeTimes.units = num2cell((1:COI)');
MUASpikeTimes.depth = (1:COI)';

try
  
  fid = fopen(filename, 'r');
  chunkInd = 1;
  prevLength = 0;

  while 1
    
    fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
    
    dat = fread(fid, [nChansTotal chunkSize], '*int16');
    
    if ~isempty(dat)
        
      
      dat = filtfilt(b,a,double(dat'));
      
      
      x = (1:size(dat,1)) + prevLength;
      
      for ch = 1:COI
         
        threshRMS = rms(dat(:,ch)) * thresh;
          
        [~, locs] = findpeaks(dat(:,ch).*(-1),x,'MinPeakHeight',threshRMS);
          
          
        MUASpikeTimes.tsec{ch} = [MUASpikeTimes.tsec{ch} , (locs./Fs)];
          
      end
      
      prevLength = prevLength + size(dat,1);
      
    else
      break
    end
    
    chunkInd = chunkInd+1;
  end
  
  
  
  fclose(fid);
catch me
  
  if ~isempty(fid)
    fclose(fid);
  end  
  rethrow(me)
  
end