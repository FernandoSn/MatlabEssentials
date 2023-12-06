function events = NPX_RemoveZerosConcatZack(filename, nChansTotal)

%Hardcoded params
chunkSize = 1000000;

events = [];
fid = []; fidOut = [];
d = dir(filename);
nSampsTotal = d.bytes/nChansTotal/2;
nChunksTotal = ceil(nSampsTotal/chunkSize);
try
  
  [~, name, ext] = fileparts(filename);
  fid = fopen(filename, 'r');
  outputFilename  = [name '_CAR' ext];
  %mdTraceFilename = [name '_medianTrace.mat'];
  fidOut = fopen(outputFilename, 'w');
  
  chunkInd = 1;
  %medianTrace = zeros(1, nSampsTotal);
  while 1 
    dat = fread(fid, [nChansTotal chunkSize], '*int16');
    if ~isempty(dat)
        
      fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
      
      ddat = diff(dat,[],2);
      
      zeroidx = find(ddat == 0);
      dzeroidx = diff(zeroidx);
      
      if sum(dzeroidx == 1)>nChansTotal
          
          edge2 = [zeroidx(dzeroidx~=1);zeroidx(end)];
          edge1 = [zeroidx(1);zeroidx(dzeroidx~=1)+1];
          remIdx = [];
          
          for ii = 1:numel(edge1)
             
              if (edge2(ii) - edge1(ii)) > (nChansTotal * 9 * 30)
                  
                  events = [events,ceil(edge1(ii)/nChansTotal) + chunkSize *(chunkInd-1)];
                  remIdx = [remIdx,ceil(edge1(ii)/nChansTotal):ceil(edge2(ii)/nChansTotal)];
                  
              end
              
          end
          
          remIdx(remIdx < 1) = 1;
          remIdx(remIdx > size(dat,2)) = size(dat,2);
          
          boolIdx = true(1,size(dat,2));
          boolIdx(remIdx) = false;
          dat = dat(:,boolIdx);
          
          
      end
    
      fwrite(fidOut, dat, 'int16');
      
    else
      break
    end
    
    chunkInd = chunkInd+1;
  end
  
  %save(mdTraceFilename, 'medianTrace', '-v7.3');
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