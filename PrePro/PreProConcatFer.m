function PreProConcatFer(FinalName)

%Make a single file out of 2 or more .dat bank files, which are the output
%of SuprePrePro. It works with the files that are in the current directory
%and overwrites the first one so you gotta be careful. Never work with
%your original files.

%IMPORTANT: files should be in alphabetical order to get the right times
%when doing manual sorting.


archivos=dir;

for aa=1:size(archivos,1)
    if strcmp(archivos(aa).name,[FinalName,'.dat'])
        error('Archivo existente, selecciona otro nombre');
    end
end

dirp = cd;
Files = ls('*.dat');

FidW = fopen([FinalName,'.dat'],'w+','ieee-le');

if(FidW==0); error('unable to open file');end

for ii = 1:size(Files,1)
    
    FileName = [dirp,'\',Files(ii,:)];
    FidR = fopen(FileName,'r','ieee-le');
    Recording = fread(FidR, inf, '*int16');
    
    fwrite(FidW, Recording, 'int16');
    fclose(FidR);
    
end

fclose(FidW);