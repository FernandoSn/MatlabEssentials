function RespVec = NPX_GetRespPS(ValveTimes, Resp,Fs)

%Respiration power spectrum

%Resp = Respiration time series.
if size(Resp,1) > size(Resp,2)
   
    Resp = Resp';
    
end
TotalTrials = length(ValveTimes.PREXTimes{1});

RespVec = zeros(size(ValveTimes.PREXTimes,1) * TotalTrials,1);


for Valve = 1:size(ValveTimes.PREXTimes,1)
    %for Conc = 1:size(ValveTimes.PREXTimes,2)
    if ~isempty(ValveTimes.PREXTimes{Valve})

        for Trial = 1:TotalTrials
        
            
            idx = round(ValveTimes.PREXTimes{Valve}(Trial) * Fs);
            idx = idx:(idx + Fs - 1);
            ps = abs(Resp(idx)).^2;
            ps = ps(1:length(ps)/2);
            freq = 0:(Fs/2) / length(ps):Fs/2;
            freq = freq(1:length(ps));
            
%             RespVec(Trial + ((Valve-1)*TotalTrials)) = (sum(ps) ./ length(ps));
            RespVec(Trial + ((Valve-1)*TotalTrials)) = (sum(ps.*freq) ./ length(ps));
%             RespVec(Trial + ((Valve-1)*TotalTrials)) = freq(ps == max(ps));
           
            
        end


    end
    %end
end