function SigStruct = SigCorrFileToStruct()

SigStruct.ZLeadEx = [];
SigStruct.ZLagEx = [];
SigStruct.ZBothEx = [];
SigStruct.ZLeadIn = [];
SigStruct.ZLagIn = [];
SigStruct.ZBothIn = [];
SigStruct.ZExIn = [];


dirp = cd; %Dir string.

SigCorrFiles = ls('*.SigCorr');

for ii = 1:size(SigCorrFiles,1)
   
    
    
    FileName = [dirp,'\',SigCorrFiles(ii,1:end)];
    
    fid = fopen(FileName,'r');
    
    if fid < 0
       error('Error in file ''%s''\n',FileName); 
    end
    
    SigVector = fread(fid,'uint16');
    
    SigMatrix = reshape(SigVector,[],3);
    
    for jj = 1:size(SigMatrix,1)
        
        switch SigMatrix(jj,1)
            case 1
                SigStruct.ZBothEx = [SigStruct.ZBothEx;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
            case 2
                SigStruct.ZLeadEx = [SigStruct.ZLeadEx;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
            case 3
                SigStruct.ZLagEx = [SigStruct.ZLagEx;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
            case 4
                SigStruct.ZBothIn = [SigStruct.ZBothIn;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
            case 5
               SigStruct.ZLeadIn = [SigStruct.ZLeadIn;ii,SigMatrix(jj,2),SigMatrix(jj,3)]; 
            case 6
                SigStruct.ZLagIn = [SigStruct.ZLagIn;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
            case 7
                SigStruct.ZExIn = [SigStruct.ZExIn;ii,SigMatrix(jj,2),SigMatrix(jj,3)];
        end 
    end 
    fclose(fid);
end