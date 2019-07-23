function remDC

archivos=ls('*.mat');

%Quita el DC de todos los archivos mat que contengan la variable "registro"
%dentro. Canal por Canal y sobreescribe el archivo.

for noArchivo = 1:size(archivos,1)
    
    if ~strcmp('F',archivos(noArchivo,1))    %evita que abra el factor de normalizacion
    
        fprintf('registro %s\n',archivos(noArchivo,:));
    
        datos = load(archivos(noArchivo,:));
        
        for ii = 1:size(datos.registro,2)
            
            fprintf('canal %u\n',ii);
            
            datos.registro(:,ii)=datos.registro(:,ii)-mean(datos.registro(:,ii));
            %datos.registro(:,ii)=(datos.registro(:,ii))./1.5; %para stock
            %143
            
        end
        
        registro=datos.registro;
        
        save(archivos(noArchivo,:),'registro');
        
    end
end
