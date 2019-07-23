function w = waveletCm(signal,Fs)

%coW=conj(wav);

time = length(signal)/Fs;

bounds = time/2;

step = time/length(signal);


w = zeros(100,length(signal));

n=0;
m=0;

timeshift = -bounds:step:bounds-step;

for scale = 1:1:100
    
    n=n+1;
    
    for ts = -bounds:step:bounds-step
        
        m=m+1;
        
        w(n,m) = sum(signal.*waveletPrueba(scale,ts,timeshift));
        %w(n,m) = sum(conv(signal,waveletPrueba(ii,jj,timeshift)));
        
    end
    
    m=0;
end