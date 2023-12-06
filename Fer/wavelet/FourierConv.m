function w = FourierConv(signal)
signal=signal-mean(signal);
len=length(signal);
w = zeros(1,len);
n=1:len;

w=zeros(length(signal)*2-1,length(signal));

for k = 1:length(signal)

    w(:,k)=conv(signal,exp(-2*pi*1i*k*n./len));
    
end