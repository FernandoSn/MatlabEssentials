function [InhAmplitude,PREXCounts] = NPX_GetInhAmplitude(ValveTimes, Resp,InhTimes, PREX, POSTX, Fs,PST,trials)

PreWnd = 5;
%bugs = [];

%Get Inhalation amplitude

if size(Resp,1) > size(Resp,2)
   
    Resp = Resp';
    
end

if nargin < 8
    trials = 1:length(ValveTimes.PREXTimes{1});
end

InhAmplitude = zeros(size(ValveTimes.PREXTimes,1) * length(trials),1);
PREXCounts = zeros(size(ValveTimes.PREXTimes,1) * length(trials),1);

n = 1;

for Valve = 1:size(ValveTimes.PREXTimes,1)
    %for Conc = 1:size(ValveTimes.PREXTimes,2)
    if ~isempty(ValveTimes.PREXTimes{Valve})

        for Trial = trials
        
            
%             idx1 = InhTimes((InhTimes >= ValveTimes.PREXTimes{Valve}(Trial))...
%                 & (InhTimes < 1 + ValveTimes.PREXTimes{Valve}(Trial)));
%             idx1 = round(idx1 .* Fs);
            
            
            idx = ((PREX >= PST(1) + ValveTimes.PREXTimes{Valve}(Trial))...
                & (InhTimes < PST(2) + ValveTimes.PREXTimes{Valve}(Trial)));
            
            %idxInh = round(InhTimes(idx).*Fs);
            idxPREX = round(PREX(idx).*Fs);
            idxPOSTX = round(POSTX(idx).*Fs);
            
            TrialBase = mean(Resp(idxPREX(1)-Fs*PreWnd:idxPREX(1)));
            
            TrialInhAmp = zeros(1,length(idxPREX));
            
            for ii = 1:length(idxPREX)
                
                RespChunk = Resp(idxPREX(ii):idxPOSTX(ii));
                
                %RespChunk = RespChunk - RespChunk(1);
                %RespChunk = RespChunk(RespChunk<=0) .* -1;
                
                
                %TrialInhAmp(ii) = sum(RespChunk);
                TrialInhAmp(ii) = min(RespChunk);
                
                if TrialBase <= TrialInhAmp(ii)
                   
                   TrialInhAmp(ii) = [];
                    
                end
            
            end
            %TrialInhAmp = Resp(idxInh);% .* -1;
            
            TrialInhW = idxPOSTX - idxPREX;
            %TrialInhW = POSTX(idx) - PREX(idx);
       
            
            TrialInhAmp = (TrialBase - TrialInhAmp);
            
            %TrialInhAmp = (TrialInhW .* (TrialBase - TrialInhAmp));
            %TrialInhAmp = (TrialInhW .* TrialInhAmp);
            
            %InhAmplitude(Trial - (trials(1)-1) + ((Valve-1)* length(trials))) = sum((TrialInhAmp) );
            PREXCounts(n) = length(TrialInhAmp);
            InhAmplitude(n) = sum(abs(TrialInhAmp(:)));
            
            
            %tempw = [(1:-0.05:0),zeros(1,100)];
            %InhAmplitude(n) = sum(TrialInhAmp .* tempw(1:length(TrialInhAmp)));
            %InhAmplitude(n) = TrialInhAmp(1) ./ TrialInhW(1);
            %InhAmplitude(n) = TrialInhW(1);
            n = n+1;
            
         
        end


    end
    %end
end