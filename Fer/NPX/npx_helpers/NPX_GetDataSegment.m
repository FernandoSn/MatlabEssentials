function NPX_GetDataSegment(filename, nChansTotal, opt, Vals)

%opt = 1, work with time
%opt = 2, work with channels

fs = 30000;
chunkSize = 1000000;
fid = []; fidOut = [];
d = dir(filename);
nSampsTotal = d.bytes/nChansTotal/2;
%nChunksTotal = ceil(nSampsTotal/chunkSize);
chunkInd = 1;

try
  
  [~, name, ext] = fileparts(filename);
  fid = fopen(filename, 'r');
  
    if opt == 1
      
      Vals = round(Vals * fs);
      TargetSamps = Vals(2) - Vals(1);
      nChunksTotal = floor(TargetSamps/chunkSize);
      outputFilename  = [name '_Segt' ext];
      fidOut = fopen(outputFilename, 'w');
      %dat = fread(fid, [nChansTotal Vals(1)], '*int16');
      fseek(fid, Vals(1)*nChansTotal*2, 'bof');
      
      %dat = fread(fid, [nChansTotal Vals(2)-Vals(1)], '*int16');
      %fwrite(fidOut, dat, 'int16');
      
      for chunkInd = 1:nChunksTotal
         fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);
         dat = fread(fid, [nChansTotal chunkSize], '*int16');        
         fwrite(fidOut, dat, 'int16');
      end
      
      dat = fread(fid, [nChansTotal mod(TargetSamps,chunkSize)], '*int16');        
      fwrite(fidOut, dat, 'int16');
      
      
    elseif opt == 2
        
        nChunksTotal = ceil(nSampsTotal/chunkSize);
        outputFilename  = [name '_SegCh' ext];
        fidOut = fopen(outputFilename, 'w');
        
          while 1
    
            fprintf(1, 'chunk %d/%d\n', chunkInd, nChunksTotal);

            dat = fread(fid, [nChansTotal chunkSize], '*int16');

            if ~isempty(dat)
                
              dat = dat(Vals(1):Vals(2),:);

              fwrite(fidOut, dat, 'int16');

            else
              break
            end

            chunkInd = chunkInd+1;
          end
       
        
        
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
