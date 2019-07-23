function [y,relativa,freq]=relativaHann(reg,sampling,resolution)

if strcmp(resolution,'no')
    
    res = length(reg);
    
else

    res=sampling/resolution;

end

w=hann(length(reg));

y=abs(fft(reg.*w,res));

y=y.^2/res;

freq=0:(sampling/2)/(length(y)/2):sampling/2;
y=y(1:length(freq));
freq=freq';


relativa=y/sum(y);

figure; plot(freq,y)
xlabel 'Frecuencia'
ylabel 'Potencia'
title 'Espectro de potencia'
