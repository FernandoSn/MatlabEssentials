function [InhTimes,PREX,POSTX,RRR,BbyB] = resp_loader(RESPfile)
load(RESPfile,'-mat')
if exist('Correct','var')
    disp('breath corrections have been made')
    % fix PREX, POSTX, and BbyB according to Correct
    Fs = 2000;
    t = 1/Fs:1/Fs:(length(RRR)/Fs);
    BbyB.Width = diff(PREX);
    for i = 1:length(PREX)-1
        if BbyB.Width(i) > 0
        BbyB.Height(i) = range(RRR(round(PREX(i)*Fs):round(PREX(i+1)*Fs)));
        % get slope for 20 ms surrounding inhalation
        sloperange = max(round(PREX(i)*Fs)-round(0.01*Fs),1):min(round(PREX(i)*Fs)+round(0.01*Fs),length(RRR));
        BbyB.Slope(i) = (RRR(sloperange(end))-RRR(sloperange(1)))/(t(sloperange(end))-t(sloperange(1)));
        else
            BbyB.Width(i) = nan;
            BbyB.Height(i) = nan;
            BbyB.Slope(i) = nan;
        end
    end
    BbyB.Corrected = 1;
end

end
