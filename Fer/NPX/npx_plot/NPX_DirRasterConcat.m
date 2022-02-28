
%Goes through every folder in FilesDir and loads data. Concats all raster
%per layer. 
%IMPORTANT: Only works if data was obtained with NPX_MasterScript


CurrentDir = cd;

FilesDir = cell(3,1);

% FilesDir{1} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX18\D5';
% FilesDir{2} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX19\D4';
% FilesDir{3} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX20\D3';
% FilesDir{1} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph2\pPCXNPX22\D10';
% FilesDir{2} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph2\pPCXNPX23\D10';
% AllRastersFileName = 'AllRastersWMorphEtBuVal';
% AllRastersFileName = 'AllRastersWMorphCarvs';

% FilesDir{1} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX18\D12';
% FilesDir{2} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX19\D11';
% FilesDir{3} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph\Good\pPCXNPX20\D10';
% FilesDir{1} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph2\pPCXNPX22\D3';
% FilesDir{2} = 'Z:\fernando\expt_sets\NPX_expt\Morphing\WMorph2\pPCXNPX23\D3';

% AllRastersFileName = 'AllRastersWMorph2EtBuVal';
% AllRastersFileName = 'AllRastersWMorph2Carvs';



Raster1L2 = [];
Raster1L3 = [];
Raster1AllPREXv = [];
Raster1AllPREXr = [];


Raster2L2 = [];
Raster2L3 = [];
Raster2AllPREXv = [];
Raster2AllPREXr = [];


Raster1L2Pr = [];
Raster1L3Pr = [];


Raster2L2Pr = [];
Raster2L3Pr = [];

BaselineRateL2 = [];
BaselineRateL3 = [];

BaselineMeanInstRateL2 = [];
BaselineMeanInstRateL3 = [];

BaselineMedianInstRateL2 = [];
BaselineMedianInstRateL3 = [];

MouseLabelL2 = [];
MouseLabelL3 = [];
MouseLabelAll = [];



for ii = 1:size(FilesDir,1)
    
   
    cd(FilesDir{ii})
    
    provfiles=dir;
    
    for kk = 1:size(provfiles,1)
        if contains(provfiles(kk).name,'.mat')
           load(provfiles(kk).name);
           break;
        end
    end
    
    ind = 3;
    L3end = L3idx(ind,2);
    %L3end = length(NPXSpikes.CluDepth);
    
    MouseLabelL2 = [MouseLabelL2, ones(1,L2idx(ind,2) - L2idx(ind,1) + 1) * ii];
    MouseLabelL3 = [MouseLabelL3, ones(1,L3end - L3idx(ind,1) + 1) * ii];
    MouseLabelAll = [MouseLabelAll, ones(1,L3end - L2idx(ind,1) + 1) * ii];
    
    
    
    Raster1AllPREXv = cat(3,Raster1AllPREXv,Raster1PREXv);
    Raster2AllPREXv = cat(3,Raster2AllPREXv,Raster2PREXv);
    Raster1AllPREXr = cat(3,Raster1AllPREXr,Raster1PREXr);
    Raster2AllPREXr = cat(3,Raster2AllPREXr,Raster2PREXr);
    
    Raster1L2 = cat(3,Raster1L2,Raster1(:,:,L2idx(ind,1):L2idx(ind,2)));
    Raster2L2 = cat(3,Raster2L2,Raster2(:,:,L2idx(ind,1):L2idx(ind,2)));
    
    Raster1L3 = cat(3,Raster1L3,Raster1(:,:,L3idx(ind,1):L3end));
    Raster2L3 = cat(3,Raster2L3,Raster2(:,:,L3idx(ind,1):L3end));
    
    
    Raster1All = cat(3,Raster1L2,Raster1L3);
    Raster2All = cat(3,Raster2L2,Raster2L3);
    
    
    
    Raster1L2Pr = cat(3,Raster1L2Pr,Raster1Pr(:,:,L2idx(ind,1):L2idx(ind,2)));
    Raster2L2Pr = cat(3,Raster2L2Pr,Raster2Pr(:,:,L2idx(ind,1):L2idx(ind,2)));
    
    Raster1L3Pr = cat(3,Raster1L3Pr,Raster1Pr(:,:,L3idx(ind,1):L3end));
    Raster2L3Pr = cat(3,Raster2L3Pr,Raster2Pr(:,:,L3idx(ind,1):L3end));
    
    Raster1AllPr = cat(3,Raster1L2Pr,Raster1L3Pr);
    Raster2AllPr = cat(3,Raster2L2Pr,Raster2L3Pr);
    
    BaselineRateL2 = [BaselineRateL2,NPXSpikes.CluFreq(L2idx(ind,1):L2idx(ind,2))];
    BaselineRateL3 = [BaselineRateL3,NPXSpikes.CluFreq(L3idx(ind,1):L3end)];
    
    [MeanInstRate,MedianInstRate] = NPX_GetBaselineRates(NPXSpikes.SpikeTimes);
    
    BaselineMeanInstRateL2 = [BaselineMeanInstRateL2,MeanInstRate(L2idx(ind,1):L2idx(ind,2))];
    BaselineMeanInstRateL3 = [BaselineMeanInstRateL3,MeanInstRate(L3idx(ind,1):L3end)];
    
    BaselineMedianInstRateL2 = [BaselineMedianInstRateL2,MedianInstRate(L2idx(ind,1):L2idx(ind,2))];
    BaselineMedianInstRateL3 = [BaselineMedianInstRateL3,MedianInstRate(L3idx(ind,1):L3end)];
    
end

cd(CurrentDir);

save([AllRastersFileName,'.mat'],'Raster1L2','Raster2L2','Raster1L3','Raster2L3',...
    'Raster1L2Pr','Raster2L2Pr','Raster1L3Pr','Raster2L3Pr',...
    'Raster1All','Raster2All','Raster1AllPr','Raster2AllPr',...
    'Raster1AllPREXv','Raster2AllPREXv','Raster1AllPREXr','Raster2AllPREXr',...
    'BaselineRateL2','BaselineRateL3',...
    'BaselineMeanInstRateL2','BaselineMeanInstRateL3',...
    'BaselineMedianInstRateL2','BaselineMedianInstRateL3',...
    'MouseLabelL2','MouseLabelL3','MouseLabelAll');

clear
