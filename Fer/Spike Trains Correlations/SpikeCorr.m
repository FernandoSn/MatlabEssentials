function CorrVec = SpikeCorr(Reference, Target, BinSize,epoch,varargin)

%if nargin <5; varargin = []; end


CumulativeMat = false;
IntCumulativeMat = false;

if BinSize > epoch; error('BinSize should be less than 1000ms'); end


NoBins = (epoch / BinSize) .* 2;



BinSize = BinSize/1000;

if ~isempty(varargin) && strcmp(varargin{1},'CumulativeMat')
    CorrVec = zeros(length(Reference)+1,NoBins);
    CumulativeMat = true;
elseif ~isempty(varargin) && strcmp(varargin{1},'IntervalCumulativeMat')
    Interval = varargin{2};
    CorrVec = zeros(ceil(length(Reference)/Interval),NoBins);
    IntCumulativeMat = true;
    
else
    CorrVec = zeros(1,NoBins);
end

for ii = 1:length(Reference)
    
  TargetSpikes = Target(Reference(ii) - epoch/1000 < Target &...
      Reference(ii) + epoch/1000 > Target);
  
  TimeSpk = Reference(ii) - epoch/1000;
  n = 1;
  
  for CurrentTime = TimeSpk:BinSize:TimeSpk + (BinSize * (NoBins - 1))
      
      SpikeCount = sum(TargetSpikes >= CurrentTime &...
          TargetSpikes < CurrentTime + BinSize);
      
      
        %CorrVec(n) = CorrVec(n) + SpikeCount;
      
    if CumulativeMat
        CorrVec(ii+1,n) = CorrVec(ii,n) + SpikeCount;
    elseif IntCumulativeMat
        CorrVec(ceil(ii/Interval),n) = CorrVec(ceil(ii/Interval),n) + SpikeCount;
    else
        CorrVec(n) = CorrVec(n) + SpikeCount;
    end
      n = n+1;
      
  end
      
    
end
  
  %CorrVec = CorrVec./length(Reference);
  %Histcorr(CorrVec,BinSize*1000,epoch);
  
