function SS = NPX_LFPSmoothing(Signal,wl)

%Func to smooth data previous to CSD calculaation with a hanning window as described in Guo,2017
%To do the same as Guo wl = 5;
%Signal is the LFP matrix, Channels x Samples;

%wl = 5;
bound = floor(wl/2);

w = hann(wl);
%w = ones(wl,1);

Chans = size(Signal,2);
Samps = size(Signal,1);

SS = zeros(Samps,Chans);


for ii = 1:bound
    for kk = 1:Chans
        SS(ii,kk) = mean(Signal(1:wl-bound+(ii-1),kk) .* w(bound+1-(ii-1):end)); 
    end   
end

for ii = bound+1:Samps-bound
    for kk = 1:Chans
        SS(ii,kk) = mean(Signal(ii-bound:ii+bound,kk) .* w); 
    end
end

for ii = Samps-bound+1 : Samps
    for kk = 1:Chans
        SS(ii,kk) = mean(Signal(ii-bound:end,kk) .* w(1:bound + 1 + Samps-ii)); 
    end
end