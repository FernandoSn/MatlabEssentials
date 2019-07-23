function normalizarReg(factorNorm)

archivos=ls('*.mat');




for noArchivo = 1:size(archivos,1)
    
        if ~strcmp('F',archivos(noArchivo,1))%evita que abra el factor de normalizacion
    
        fprintf('registro %s\n',archivos(noArchivo,:));
    
        datos = load(archivos(noArchivo,:));
        
        for ii = 1:size(datos.registro,2)
            
            fprintf('canal %u\n',ii);
            
            datos.registro(:,ii)=datos.registro(:,ii).*factorNorm(ii);
            
        end
        
        registro=datos.registro;
        
        save(archivos(noArchivo,:),'registro');
        
        end
end


