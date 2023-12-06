function controlWave(name1,name2)

archivos=ls('*.mat');


n = 4;

for noArchivo = 1:size(archivos,1)
    
    
        datos = load(archivos(noArchivo,:));
    
    for channel = 1:3
        
        fprintf ('Analizando canal %u del reg %s...\n',channel,archivos(noArchivo,:));
        
        
        [deltaRel,deltaVar,tetaRel,tetaVar,...
    alphaRel,alphaVar,betaRel,betaVar,gammaRel,gammaVar] = controlF(datos.registro,channel,[]);
    rel = {['rel ',archivos(noArchivo,:)],deltaRel,tetaRel,alphaRel,betaRel,gammaRel,...
        deltaRel+tetaRel+alphaRel+betaRel+gammaRel};
    var = {['abs ',archivos(noArchivo,:)],deltaVar,tetaVar,alphaVar,betaVar,gammaVar,...
        deltaVar+tetaVar+alphaVar+betaVar+gammaVar};
    xlswrite([name1,'.xlsx'],rel,channel,['C',num2str(n)]);
    xlswrite([name2,'.xlsx'],var,channel,['C',num2str(n)]);
    
    
    end
    n = n+1;
end

        direc = cd;
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name1,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI';
        ewb.Worksheets.Item(2).Name='CxD';
        ewb.Worksheets.Item(3).Name='AMG';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name2,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI';
        ewb.Worksheets.Item(2).Name='CxD';
        ewb.Worksheets.Item(3).Name='AMG';
        ewb.Save
        ewb.Close(false)
        e.Quit
