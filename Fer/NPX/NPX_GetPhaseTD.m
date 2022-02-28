function [trainlabel, traindata] = NPX_GetPhaseTD(RasterPh,InhCycle, Trials, isPhaseMean)


%Returns a matrix of phases for RasterPh and a matrix of times for Raster.

PST = [InhCycle-1 InhCycle];

for V = 1:size(RasterPh,1)
    for U = 1:size(RasterPh,3)
            for T = 1:length(Trials)

                %Raster{V,U}{Trials(T)}(Raster{V,U}{Trials(T)}>-.001 &
                %Raster{V,U}{Trials(T)}<.001) = [];
                
                if isPhaseMean                  
                    PSTHtrials{V,U,T} = find((RasterPh{V,1,U}{Trials(T)}>PST(1)) & (RasterPh{V,1,U}{Trials(T)}<PST(2)));                   
                else                    
                    PSTHtrials{V,U,T} = find((RasterPh{V,1,U}{Trials(T)}>PST(1)) & (RasterPh{V,1,U}{Trials(T)}<PST(2)),1);                    
                end
                               

                if isempty(PSTHtrials{V,U,T})
                    PSTHtrials{V,U,T} = 0;
                else    
                    PSTHtrials{V,U,T} = mean(RasterPh{V,1,U}{Trials(T)}(PSTHtrials{V,U,T}));
                end

            end
    end
end







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