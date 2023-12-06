function controlCoHWaveSWD(name1,name2,name3)

archivos=ls('*.mat');


n = 4;

for noArchivo = 1:size(archivos,1)
    
    
        datos = load(archivos(noArchivo,:));
    
    for channel = 1:6
        
        channel1 = channel; channel2 = 5;
        if channel == 5; channel1 = 1; channel2 = 2; end
        if channel == 6; channel1 = 3; channel2 = 4; end
        
        fprintf ('Analizando canal %u contra %u del reg %s...\n',channel1,channel2,archivos(noArchivo,:));
        
        
        [deltaCoH,deltaCross,tetaCoH,tetaCross,...
    alphaCoH,alphaCross,betaCoH,betaCross,gammaCoH,gammaCross,~,~,~,~,...
    deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar] = controlCoHSWD(datos.registro,channel1,channel2);
    

    coh = {['coh ',archivos(noArchivo,:)],deltaCoH,tetaCoH,alphaCoH,betaCoH,gammaCoH...
        ,deltaCoH+tetaCoH+alphaCoH+betaCoH+gammaCoH};
    cross = {['crossRel ',archivos(noArchivo,:)],deltaCross,tetaCross,alphaCross,betaCross,gammaCross...
        ,deltaCross+tetaCross+alphaCross+betaCross+gammaCross};
    crossVar = {['crossAbs ',archivos(noArchivo,:)],deltaCrossVar,tetaCrossVar,alphaCrossVar,betaCrossVar,gammaCrossVar...
        ,deltaCrossVar+tetaCrossVar+alphaCrossVar+betaCrossVar+gammaCrossVar};
    
    
    xlswrite([name1,'.xlsx'],coh,channel,['C',num2str(n)]);
    xlswrite([name2,'.xlsx'],cross,channel,['C',num2str(n)]);
    xlswrite([name3,'.xlsx'],crossVar,channel,['C',num2str(n)]);
    
    
    end
    n = n+1;
end

        direc = cd;
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name1,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxFI-VBT';
        ewb.Worksheets.Item(2).Name='CxFD-VBT';
        ewb.Worksheets.Item(3).Name='CxPI-VBT';
        ewb.Worksheets.Item(4).Name='CxPD-VBT';
        ewb.Worksheets.Item(5).Name='CxFI-CxFD';
        ewb.Worksheets.Item(6).Name='CxPI-CxPD';
        ewb.Save
        ewb.Close(false)
        e.Quit