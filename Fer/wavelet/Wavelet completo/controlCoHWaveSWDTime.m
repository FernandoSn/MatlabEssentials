function controlCoHWaveSWDTime(name)
archivos=ls('*.mat');


%n = 4;

Datos = cell(6,6);
for noArchivo = 1:size(archivos,1)
    
    
        datos = load(archivos(noArchivo,:));
    
    for channel = 1:6 %Escribir 6 aqui,
        
        
        channel1 = channel; channel2 = 5;
        if channel == 5; channel1 = 1; channel2 = 2; end
        if channel == 6; channel1 = 3; channel2 = 4; end
        
        fprintf ('Analizando canal %u contra %u del reg %s...\n',channel1,channel2,archivos(noArchivo,:));
        
        
        reg1 = datos.registro(:,channel1);
        reg2 = datos.registro(:,channel2);


    fprintf('wavelet coherence spectrum\n');

    coH = waveletCoherence(reg1,reg2,2000,1/12);
    
    Datos{1,channel} = [Datos{1,channel};mean(coH(52:118,:),1)]; %Total
    Datos{2,channel} = [Datos{2,channel};mean(coH(96:118,:),1)]; %Delta
    Datos{3,channel} = [Datos{3,channel};mean(coH(86:95,:),1)]; %Teta
    Datos{4,channel} = [Datos{4,channel};mean(coH(80:85,:),1)]; %Alfa
    Datos{5,channel} = [Datos{5,channel};mean(coH(68:79,:),1)]; %Beta
    Datos{6,channel} = [Datos{6,channel};mean(coH(51:67,:),1)]; %Gamma
    
    
    
    end
    %n = n+1;
end

save([name,'.mat'],'Datos')