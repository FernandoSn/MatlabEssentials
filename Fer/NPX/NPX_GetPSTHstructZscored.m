function PSTHstructZscored = NPX_GetPSTHstructZscored(PSTHstruct, PSTHstructPr,IdxVec)

if ~isempty(IdxVec)
    PSTHstruct.KDF = PSTHstruct.KDF(:,IdxVec);
    PSTHstruct.KDFe = PSTHstruct.KDFe(:,IdxVec);
    PSTHstructPr.KDF = PSTHstructPr.KDF(:,IdxVec);
    PSTHstructPr.KDFe = PSTHstructPr.KDFe(:,IdxVec);
end

PSTHstructZscored.KDFrawave = PSTHstruct.KDF;

PSTHstructZscored.KDFt = PSTHstruct.KDFt;

PSTHstructZscored.realPST = PSTHstruct.realPST;

PSTHstructZscored.KDFZstd = PSTHstructPr.KDFe;

PSTHstructZscored.KDFZave = PSTHstructPr.KDF;

for kk = 1:size(PSTHstructZscored.KDFrawave,2)
    
    
    
    Avez = mean(cell2mat(PSTHstructZscored.KDFZave(:,kk)),1);
    Avez = mean(Avez(PSTHstructZscored.realPST));
    
    Stdz = mean(cell2mat(PSTHstructZscored.KDFZstd(:,kk)),1);
    Stdz = mean(Stdz(PSTHstructZscored.realPST));
    
    
    
   for ii = 1:size(PSTHstructZscored.KDFrawave,1)
       
       
       
%        PSTHstructZscored.KDF{ii,kk} = ((PSTHstructZscored.KDFrawave{ii,kk} - ...
%            mean(PSTHstructZscored.KDFZave{ii,kk}(PSTHstructZscored.realPST))))...
%            ./ mean(PSTHstructZscored.KDFZstd{ii,kk}(PSTHstructZscored.realPST));
       
       PSTHstructZscored.KDF{ii,kk} = (PSTHstructZscored.KDFrawave{ii,kk}-Avez)./Stdz;

       
       Infornan = isnan(PSTHstructZscored.KDF{ii,kk}) | isinf(PSTHstructZscored.KDF{ii,kk});
       
       if sum(Infornan) >0 
           
           PSTHstructZscored.KDF{ii,kk}(Infornan) = 0;
           
           %fprintf('nanorinf %d \n',sum(Infornan)); 
       end      
   end
end

