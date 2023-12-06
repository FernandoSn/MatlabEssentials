function FullWCrossCorrNorm = ControlCrossCorrWaveNorm(name1,name2)
archivos=ls('*.mat');


n = 4;

FullWCrossCorrNorm = cell(size(archivos,1),2);

for noArchivo = 1:size(archivos,1)
    
    FullWCrossCorrNorm{noArchivo,1} = archivos(noArchivo,:);
    CrossStructStack = cell(1,3);


    datos = load(archivos(noArchivo,:));
    tag = 0;
    
    for channel = 1:3
        
        channel1 = channel; channel2 = channel1+1;
        if channel == 3; channel2 = channel; channel1 = 1; end
        
        fprintf ('Analizando canal %u contra %u del reg %s...\n',channel1,channel2,archivos(noArchivo,:));
        
        
        fprintf ('Wavelet transform and Wavelet Cross Correlation Analysis...\n');
        
        [WCrossCorrA, WCrossCorrR, freq, ~]...
            = waveletCrossCorrelationNorm(datos.registro(:,channel1),datos.registro(:,channel2),1000,1/12);
        
        fprintf ('Separating into bands...\n');
        
        [CrossStruct]...
            = CrossCorrWaveBands(WCrossCorrA,WCrossCorrR,freq);
    

        CrossStruct.CrossDriverABands{1} = ['WCrossCorr ',archivos(noArchivo,:)];
        CrossStruct.CrossTargetABands{1} = ['WCrossCorr ',archivos(noArchivo,:)];
        CrossStruct.CrossDriverRBands{1} = ['WCrossCorr ',archivos(noArchivo,:)];
        CrossStruct.CrossTargetRBands{1} = ['WCrossCorr ',archivos(noArchivo,:)];
    
        
        fprintf ('Writing Driver to Excel...\n');
    
        tag = tag + 1;
        
        xlswrite([name1,'.xlsx'],CrossStruct.CrossDriverABands,tag,['C',num2str(n)]);
        xlswrite([name2,'.xlsx'],CrossStruct.CrossDriverRBands,tag,['C',num2str(n)]);
        
        
        fprintf ('Writing Target to Excel...\n');
        
        tag = tag + 1;
        
        xlswrite([name1,'.xlsx'],CrossStruct.CrossTargetABands,tag,['C',num2str(n)]);
        xlswrite([name2,'.xlsx'],CrossStruct.CrossTargetRBands,tag,['C',num2str(n)]);
        
        
        fprintf ('Copying the struct into a cell...\n');
        
        CrossStructStack{channel} = CrossStruct;
       
    end
    n = n+1;
    
    fprintf ('Copying the struct stack...\n');
    
    FullWCrossCorrNorm{noArchivo,2} = CrossStructStack;
    
end

        fprintf ('Saving the full Wavelet Cross Correlation into a .mat...\n');
        
        %save('FullWCrossCorrNorm.mat','FullWCrossCorrNorm');
        
        
        fprintf ('Setting Excel Stuff...\n');

        direc = cd;
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name1,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxD->CxI';
        ewb.Worksheets.Item(2).Name='CxI->CxD';
        ewb.Worksheets.Item(3).Name='AMG->CxD';
        ewb.Worksheets.Item(4).Name='CxD->AMG';
        ewb.Worksheets.Item(5).Name='AMG->CxI';
        ewb.Worksheets.Item(6).Name='CxI->AMG';
        ewb.Save
        ewb.Close(false)
        e.Quit
        
        e=actxserver('Excel.Application');
        ewb=e.Workbooks.Open([direc,'\',name2,'.xlsx']);
        ewb.Worksheets.Item(1).Name='CxD->CxI';
        ewb.Worksheets.Item(2).Name='CxI->CxD';
        ewb.Worksheets.Item(3).Name='AMG->CxD';
        ewb.Worksheets.Item(4).Name='CxD->AMG';
        ewb.Worksheets.Item(5).Name='AMG->CxI';
        ewb.Worksheets.Item(6).Name='CxI->AMG';
        ewb.Save
        ewb.Close(false)
        e.Quit