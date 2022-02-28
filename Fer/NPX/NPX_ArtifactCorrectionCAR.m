function medianTrace = NPX_ArtifactCorrectionCAR(filename, nChansTotal,OEDir,Events)

currentDir = cd;

% Subtracts median of each channel, then subtracts median of each time
% point and artifact correction.
%
% should make chunk size as big as possible so that the medians of the
% channels differ little from chunk to chunk.
chunkSize = 1000000;

fid = []; fidOut = [];

d = dir(filename);
nSampsTotal = d.bytes/nChansTotal/2;
nChunksTotal = ceil(nSampsTotal/chunkSize);
try
  
  [pathstr, name, ext] = fileparts(filename);
  fid = fopen(filename, 'r');
  
  tempFilename  = [name '_temp' ext];
  
  fidOut = fopen(tempFilename, 'w');
  
  % theseInds = 0;
  chunkInd = 1;
  while 1
    
    fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
    
    dat = fread(fid, [nChansTotal chunkSize], '*int16');
    
    if ~isempty(dat)
        
%       if Events(event)>
      
      dat = bsxfun(@minus, dat, median(dat,2)); % subtract median of each channel
      
      fwrite(fidOut, dat, 'int16');
      
    else
      break
    end
    
    chunkInd = chunkInd+1;
  end
  
  fclose(fid);
  fclose(fidOut);
  
catch me
  
  if ~isempty(fid)
    fclose(fid);
  end
  
  if ~isempty(fidOut)
    fclose(fidOut);
  end
  
  
  rethrow(me)
  
end


movefile(filename, 'originalRecordingconti.dat');
movefile(tempFilename, filename);

cd(OEDir);
NPX_RemoveLightArtifacts(Events);
cd(currentDir);

movefile(filename, tempFilename);
movefile('originalRecordingconti.dat', filename);

try
  
  fid = fopen(tempFilename, 'r');
  
  outputFilename  = [name '_CAR' ext];
  
  mdTraceFilename = [name '_medianTrace.mat'];
  
  fidOut = fopen(outputFilename, 'w');
  
  % theseInds = 0;
  chunkInd = 1;
  medianTrace = zeros(1, nSampsTotal);
  while 1
    
    fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
    
    dat = fread(fid, [nChansTotal chunkSize], '*int16');
    
    if ~isempty(dat)
      
      chunkIni = (chunkInd-1)*chunkSize+1;
      chunkEnd = (chunkInd-1)*chunkSize+size(dat,2);
    
      tm = median(dat,1);
      dat = bsxfun(@minus, dat, tm); % subtract median of each time point
      
      fwrite(fidOut, dat, 'int16');
      medianTrace(chunkIni:chunkEnd) = tm;
      
    else
      break
    end
    
    chunkInd = chunkInd+1;
  end
  
  save(mdTraceFilename, 'medianTrace', '-v7.3');
  fclose(fid);
  fclose(fidOut);
  delete(tempFilename)
  
catch me
  
  if ~isempty(fid)
    fclose(fid);
  end
  
  if ~isempty(fidOut)
    fclose(fidOut);
  end
  
  
  rethrow(me)
  
end