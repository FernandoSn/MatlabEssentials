function cortaRegistro(canal1, canal2)


archivos=ls('*.mat');

%Quita el DC de todos los archivos mat que contengan la variable "registro"
%dentro. Canal por Canal y sobreescribe el archivo.

for noArchivo = 1:size(archivos,1)
    
        fprintf('se corta de canal %u a %u del registro %s\n',canal1,canal2,archivos(noArchivo,:));
    
        datos = load(archivos(noArchivo,:));
        
        registro=datos.registro(:,canal1:canal2);
        
        save(archivos(noArchivo,:),'registro');
end