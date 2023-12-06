function [InhTimes,PREX,POSTX,RRR,BbyB] = FreshBreath(RESP,Fs,t,FVOpens,FVCloses,FilesKK)

[a,b] = fileparts(FilesKK.AIP);
RESPfile = [a,filesep,b,'.resp'];
if exist(RESPfile,'file')
    [InhTimes,PREX,POSTX,RRR,BbyB] = resp_loader(RESPfile);
else
    
    %% Final Valve Switch can affect the flow rate in the respiration signal
    % causing a sudden downward shift which looks like an inhalation.
    [asRESP] = FV_ArtifactRemover(FVOpens,FVCloses,RESP,Fs,t);
    
    [RRR,sgdtresp,Rrms,flt] = FilterAndFlatten(asRESP,Fs,t);
    
    %%
    % Find inhalation peaks
    [InPks,InLocs] = findpeaks(-flt,'MinPeakHeight',10,'MinPeakDistance',round(1/20*Fs));
    
    % Legitimize Inhalation Peaks by the range of values in between them.
    IL = InLocs;
    IP = InPks;
    
    if isempty(IL)
        asRESP = 100*sin(10*t);
        [RRR,sgdtresp,Rrms,flt] = FilterAndFlatten(asRESP,Fs,t);
        [InPks,InLocs] = findpeaks(-flt,'MinPeakHeight',10,'MinPeakDistance',round(1/20*Fs));
        IL = InLocs;
        IP = InPks;
        disp('fake breath applied')
    end
        
    for i = 1:length(IL)-1
        breathsize(i) = range(sgdtresp(IL(i):IL(i+1)));
    end
   
    BreathPoint = [breathsize',diff(IL),IP(1:end-1)];
    
    for i = 1:3
        ym = movingAverage(BreathPoint(:,i),33);
        ys = movingvar(BreathPoint(:,i),33).^.5;
        
        VadVPS(:,i) = (BreathPoint(:,i)-ym) > 5*ys | (BreathPoint(:,i)-ym) < -5*ys;
    end
    
    BadBPS = sum(VadVPS,2)>1;
    
    ILGood = IL(~BadBPS);
   
    %%
    % Inhalation zero crossings
    zcSignal = sgdtresp./Rrms; % Divide by the rms, to normalize the signal.
    zcSignal = zcSignal+.2;
    a = find(zcSignal(1:end-1).*zcSignal(2:end)<0);
    Rd = diff(sgdtresp);
    aposgoing = find(Rd(a)>0);
    aneggoing = find(Rd(a)<0);
    badX = 1;
    while sum(badX)>0
        izx = repmat(a,size(ILGood'))-repmat(ILGood',size(a));
        % zeroXtimes - inhalation times(<0 means zeroX happened first)
        izxpost = izx(aposgoing,:); izxpost(izxpost<0) = inf; % Postinhalation crossings must be before an inhalation and positive going.
        izxpre = izx(aneggoing,:); izxpre(izxpre>0) = inf; % Preinhalation crossings must be before an inhalation and negative going.
        
        POSTX = ILGood+min((izxpost))';
        PREX = ILGood-min(abs(izxpre))';
        
        infiniX = isinf(POSTX)|isinf(PREX);
        POSTX = POSTX(~infiniX);
        PREX = PREX(~infiniX);
        ILGood = ILGood(~infiniX);
        
        badX = find(diff(PREX)==0 | diff(POSTX) == 0);
        badILs = badX(badX<length(PREX) & badX>=1)+1;
        length(badILs)
        
        ILGood(badILs) = [];
    end
    
    InhTimes = ILGood'./Fs;
    PREX = PREX'./Fs;
    POSTX = POSTX'./Fs;
    
    for i = 1:length(PREX)-1
        finalbreathsize(i) = range(sgdtresp(round(PREX(i)*Fs):round(PREX(i+1)*Fs)));
        
        % get slope for 20 ms surrounding inhalation
        sloperange = max(round(PREX(i)*Fs)-round(0.01*Fs),1):min(round(PREX(i)*Fs)+round(0.01*Fs),length(sgdtresp));
        breathslopes(i) = (sgdtresp(sloperange(end))-sgdtresp(sloperange(1)))/(t(sloperange(end))-t(sloperange(1)));
    end
    
    breathintervals = diff(PREX);
    
    BbyB.Height = finalbreathsize;
    BbyB.Width = breathintervals;
    BbyB.Slope = breathslopes;
    
    save(RESPfile,'InhTimes','PREX','POSTX','RRR','BbyB')
end
end

function [asRESP] = FV_ArtifactRemover(FVOpens,FVCloses,RESP,Fs,t)
    if ~isempty(FVOpens)
        numFVevents = min(length(FVOpens),length(FVCloses));
        FVOpens = FVOpens(1:numFVevents);
        FVCloses = FVCloses(1:numFVevents);
        artifactshift = zeros(1,length(FVOpens));
        asRESP = RESP;
        astRESP = RESP;
        for i = 1:length(FVOpens)
            FVOsamples = (round((FVOpens(i))*Fs):round((FVOpens(i)+.15)*Fs));
            FVOsamples = FVOsamples(FVOsamples<length(RESP));
            astRESP(FVOsamples) = smooth(RESP(FVOsamples),99);
            FVCsamples = (round((FVCloses(i))*Fs):round((FVCloses(i)+.15)*Fs));
            FVCsamples = FVCsamples(FVCsamples<length(RESP));
            astRESP(FVCsamples) = smooth(RESP(FVCsamples),99);
            FVsamples = (round((FVOpens(i)-1)*Fs):round((FVCloses(i)+1)*Fs));
            FVsamples = FVsamples(FVsamples<length(astRESP));
            [pk,lc] = findpeaks(abs(RESP(FVsamples)-astRESP(FVsamples)),'minpeakdistance',1800);
            lc = min(lc,length(FVsamples)-26);
            if length(lc)>1
                asRESP(FVsamples(lc(2)-25:lc(2)+25)) = interp1([1,51],[asRESP(FVsamples(lc(2)-25)),asRESP(FVsamples(lc(2)+25))],1:51);
                asRESP(FVsamples(lc(1)-25:lc(1)+25)) = interp1([1,51],[asRESP(FVsamples(lc(1)-25)),asRESP(FVsamples(lc(1)+25))],1:51);
            end
            %
            
            if length(lc) == 2
                FVsamples2 = (FVsamples(1)+lc(1):FVsamples(1)+lc(2));
            else
                FVsamples2 = (round(FVOpens(i)*Fs):round(FVCloses(i)*Fs))+45;
            end
            P = polyfit(1:length(FVsamples2),asRESP(FVsamples2),1);
            asRESP(FVsamples2) = asRESP(FVsamples2)-((1:length(FVsamples2))*P(1));
            
            % correct differences in range between the early and late part
            % of the FV opening period
            CLmedian = median(asRESP(FVsamples([1:2000])));
            CLrange = mean([range(asRESP(FVsamples(1:2000))),range(asRESP(FVsamples(end-2000:end)))]);
            CLmin = min(asRESP(FVsamples([1:2000])));
            CLmax = max(asRESP(FVsamples([1:2000])));
            rangediff = range(asRESP(FVsamples2))/CLrange;
            mediandiff = median(asRESP(FVsamples2))-CLmedian;
            asRESP(FVsamples2) = asRESP(FVsamples2)/rangediff-(mediandiff);
        end
    else
        asRESP = RESP;
    end
end

function [RRR,sgdtresp,Rrms,flt] = FilterAndFlatten(asRESP,Fs,t)
    
    % Savitzky-Golay filter in a n-second window. This kills faux inhales
    % (little peaks)
    sgresp = sgolayfilt(asRESP,5,(0.185*Fs)+1);
    
    % Local detrend in 1.5 second windows with 1 second overlap. This removes
    % baseline shifts from breathing.
    sgdtresp = locdetrend(sgresp,Fs,[2 1.5]);
    
    % Find windowed rms in 1 second windows for setting threshold
    Rrms = (movingAverage(sgdtresp.^2,1*Fs)).^.5;
    
    % Flattening the signal
    flt = sgdtresp;
    flt(sgdtresp>-.7*Rrms & sgdtresp<Rrms) = 0;
    
    RRR = sgdtresp;
end