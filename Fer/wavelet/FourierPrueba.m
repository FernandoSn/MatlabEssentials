function w = FourierPrueba(signal)

len=length(signal);
w = zeros(1,len);
n=1:len;

for k = 1:length(signal)

    w(k)=sum(signal.*exp(-2*pi*1i*k*n./len));
    
end