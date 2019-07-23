function signal = reconOrig(wav,vScale,deltaJ)

vScale = vScale';

signal = zeros(1,size(wav,2));
for ii = 1:size(wav,2)
    
    signal(ii) = sum(real(wav(:,ii))./sqrt(vScale));
    signal(ii) = (((deltaJ)*sqrt(1))/(0.776*pi^(-0.25)))*signal(ii);
    
end


%Reconstruccion de la señal original
%Se necesita la matriz compleja de wavelets(wav)
%El vector con las escalas originales (vScale)
%La proporcion de suboctavas. (deltaJ).
