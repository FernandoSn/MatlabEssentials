function events = NPX_DenoiseRawZack(filename, nChansTotal,chGroups,chRange)

events = [];
[b,a]=butter(2,[300/(30000/2),6000/(30000/2)]);
%Hardcoded params
chunkSize = 1000000;

amplification = 500;
vThresh = 400 * (amplification/100);
deltaVThresh = 200 * (amplification/100);
baseV = 50 * (amplification/100);

minXChannels = round(nChansTotal * 0.125);
maxWnd = 0.007 * 30000;

if nargin<3
    chGroups = 1;
end

if nargin<4
   chRange = [1,nChansTotal];
end

if mod(diff(chRange)+1,chGroups) ~=0
   error('Channels should be divisible by groups'); 
end

nChans = diff(chRange)+1;
blockSize = nChans/chGroups;

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
      dat = dat(chRange(1):chRange(2),:);
      dat = bsxfun(@minus, dat, median(dat,2)); % subtract median of each channel
      temp = int16(filtfilt(b,a,double(dat)')');
      
      %%%%%Remove artifacts%%%%%%%%%%%%%%%%%%%
      booldv = [false,sum(abs(diff(dat,1,2))>deltaVThresh,1)>minXChannels];
      idxdv = find(booldv);
      if ~isempty(idxdv)
      idxdv = idxdv([true,diff(idxdv) ~= 1]); %remove consecutive ind.
      for ii = 1:length(idxdv)
          ind1 = idxdv(ii)+1;
          ind2 = idxdv(ii)+1+maxWnd;
          if ind2>size(dat,2)
              ind2 = size(dat,2);
          end          
          tempmed = median(abs(dat(:,ind1:ind2)),1);
          idxBaseV = find(tempmed<baseV,1);
          if isempty(idxBaseV)
              idxBaseV = ind2;
          else
              idxBaseV = idxBaseV + ind1-1;
          end
          if max(sum(abs(dat(:,idxdv(ii):idxBaseV))>vThresh,1))>minXChannels %5 channels, arbitrary choice.
              %temp(:,ind1-61:ind1+240) = 0;
              temp(:,ind1-91:idxBaseV) = 0;
              events = [events,(ind1-1) + size(dat,2)*(chunkInd-1)];
          end
      end
      end
      dat = temp;
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      for ii = 1:blockSize:nChans
          dat(ii:ii+blockSize-1,:) = bsxfun(@minus, dat(ii:ii+blockSize-1,:), median(dat(ii:ii+blockSize-1,:),1));      
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