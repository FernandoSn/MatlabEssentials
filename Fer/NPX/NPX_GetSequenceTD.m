function [trainlabel,traindata,sortedlatidx] = NPX_GetSequenceTD(Raster,PST,Trials,ValveTimes,PREX)

if nargin >3
    InhIdx = PST;
    PSTs = NPX_GetPSTs(ValveTimes, PREX, [], Trials,InhIdx);
else   
    PSTs = cell(size(Raster,1), length(Trials));
    for ii = 1:numel(PSTs)
       PSTs{ii} = PST; 
    end   
end

%[~, PSTHtrials, PSTHt] = PSTHmaker_Beast(Raster, PST, BinSize, Trials);
% for V = 1:size(Raster,1)
%     for C = 1:size(Raster,2)
%         for U = 1:size(Raster,3)
%             if nargin<4 || isempty(Trials)
%                 Trials = 1:length(Raster{V,C,U});
%             end
%                for T = 1:length(Trials)
%                    %Raster{V,C,U}{Trials(T)}(Raster{V,C,U}{Trials(T)}>-.001 & Raster{V,C,U}{Trials(T)}<.001) = [];
%                    
%                    PSTHtrials{V,C,U,T} = find((Raster{V,C,U}{Trials(T)}>PST(1)) & (Raster{V,C,U}{Trials(T)}<PST(2)),1);
%                    
%                    if isempty(PSTHtrials{V,C,U,T})
%                        PSTHtrials{V,C,U,T} = PST(2)+0.1;
%                    else    
%                        PSTHtrials{V,C,U,T} = Raster{V,C,U}{Trials(T)}(PSTHtrials{V,C,U,T});
%                    end
%                    
%                end
%         end
%     end
% end


PSTHtrials = NPX_PSTHmaker(Raster, PSTs, Trials,true);

    A = cell2mat(PSTHtrials);

if ndims(A) == 3
    B = permute(A,[3,1,2]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,3),1);
    trainlabel = trainlabel(:);
    
else
    B = permute(A,[4,1,2,3]);
    
    traindata = reshape(B,size(B,1)*size(B,2),[]);
    trainlabel = repmat(1:size(A,1),size(PSTHtrials,4),1);
    trainlabel = trainlabel(:);
    
end

maxLat = max(cell2mat(PSTs),[],'all');

[sortedlat,sortedlatidx] = sort(traindata');

sortedlatidx = sortedlatidx';
sortedlat = sortedlat';

sortedlatidx(sortedlat==(maxLat+0.1)) = 0;

traindata(traindata==(maxLat+0.1)) = 0;
end


