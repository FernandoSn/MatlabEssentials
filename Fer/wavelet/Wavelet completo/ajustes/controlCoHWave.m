function controlCoHWave(name1,name2,name3,name4,name5,name6)

archivos=ls('*.mat');


n = 4;

for noArchivo = 1:size(archivos,1)
    
    
        datos = load(archivos(noArchivo,:));
    
    for channel = 1:3
        
        channel1 = channel; channel2 = channel1+1;
        if channel == 3; channel1 = channel; channel2 = 1; end
        
        fprintf ('Analizando canal %u contra %u del reg %s...\n',channel1,channel2,archivos(noArchivo,:));
        
        
        [deltaCoH,deltaCross,tetaCoH,tetaCross,...
    alphaCoH,alphaCross,betaCoH,betaCross,gammaCoH,gammaCross,coH,crossSpectrum,freq,crossSpectrumVar,...
    deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar] = controlCoH(datos.registro,channel1,channel2);
    

    coh = {['coh ',archivos(noArchivo,:)],deltaCoH,tetaCoH,alphaCoH,betaCoH,gammaCoH...
        ,deltaCoH+tetaCoH+alphaCoH+betaCoH+gammaCoH};
    cross = {['crossRel ',archivos(noArchivo,:)],deltaCross,tetaCross,alphaCross,betaCross,gammaCross...
        ,deltaCross+tetaCross+alphaCross+betaCross+gammaCross};
    crossVar = {['crossAbs ',archivos(noArchivo,:)],deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar...
        ,deltaCrossVar+tetaCrossVar+alphaCrossVar+betaCrossVar+gammaCrossVar};
    
    
    xlswrite([name1,'.xlsx'],coh,channel,['C',num2str(n)]);
    xlswrite([name2,'.xlsx'],cross,channel,['C',num2str(n)]);
    xlswrite([name3,'.xlsx'],crossVar,channel,['C',num2str(n)]);
    
    [deltaCoH,deltaCross,tetaCoH,tetaCross,...
    alphaCoH,alphaCross,betaCoH,betaCross,gammaCoH,gammaCross,...
    deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar] = controlCoHCuadrado(coH,crossSpectrum,freq,crossSpectrumVar);
    
    coh = {['coh ',archivos(noArchivo,:)],deltaCoH,tetaCoH,alphaCoH,betaCoH,gammaCoH...
        ,deltaCoH+tetaCoH+alphaCoH+betaCoH+gammaCoH};
    cross = {['crossRel ',archivos(noArchivo,:)],deltaCross,tetaCross,alphaCross,betaCross,gammaCross...
        ,deltaCross+tetaCross+alphaCross+betaCross+gammaCross};
    crossVar = {['crossAbs ',archivos(noArchivo,:)],deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar...
        ,deltaCrossVar+tetaCrossVar+alphaCrossVar+betaCrossVar+gammaCrossVar};

    xlswrite([name4,'.xlsx'],coh,channel,['C',num2str(n)]);
    xlswrite([name5,'.xlsx'],cross,channel,['C',num2str(n)]);
    xlswrite([name6,'.xlsx'],crossVar,channel,['C',num2str(n)]);
    
    

    
    end
    n = n+1;
end

        direc = cd;
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name1,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name2,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name3,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name4,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name5,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name6,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxI-CxD';
        ewb.Worksheets.Item(2).Name='CxD-AMG';
        ewb.Worksheets.Item(3).Name='AMG-CxI';
        ewb.Save
        ewb.Close(false)
        e.Quit
