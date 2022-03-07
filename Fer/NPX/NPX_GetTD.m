function [ltd,td,tatd,n_bins] = NPX_GetTD(Raster,PST,BinSize,Trials)

if nargin<4
    
    [~, PSTHtrials, PSTHt] = NPX_PSTHmaker(Raster, PST, BinSize);
    
else

    [~, PSTHtrials, PSTHt] = NPX_PSTHmaker(Raster, PST, BinSize, Trials);

end

n_bins = length(PSTHt);

%
% for V = 1:size(PSTHtrials,1)
%     for U = 1:size(PSTHtrials,2)
%         for T = 1:size(PSTHtrials,3)
%             PSTHtrials{V,U,T} = shake(PSTHtrials{V,U,T});
%         end
%     end
% end


%% for "temporal" code.  normalizing away all spike count changes.
% a = cellfun(@sum,PSTHtrials);
% aa = mat2cell(a,ones(size(a,1),1),ones(size(a,2),1),ones(size(a,3),1));
% b = cellfun(@rdivide,PSTHtrials,aa,'uni',0);
% pt = b;
% pt(a==0) = {ones(size(b{1,1,1}))/sum(ones(size(b{1,1,1})))};
% PSTHtrials = pt;

%%

for ii = 1:numel(PSTHtrials)
   
    if isempty(PSTHtrials{ii})
       
        PSTHtrials{ii} = nan(1,n_bins);
        
    end
    
end


    A = cell2mat(PSTHtrials);

if ndims(A) == 3
    B = permute(A,[3,1,2]);
    
    td = reshape(B,size(B,1)*size(B,2),[]);
    ltd = repmat(1:size(A,1),size(PSTHtrials,3),1);
    ltd = ltd(:);
    

else
    B = permute(A,[4,1,2,3]);
    
    td = reshape(B,size(B,1)*size(B,2),[]);
    ltd = repmat(1:size(A,1),size(PSTHtrials,4),1);
    ltd = ltd(:);
end

idx = ~any(isnan(td),2);

td = td(idx,:);
ltd = ltd(idx);
stimuli = unique(ltd);

tatd = zeros( numel(stimuli) , size(td,2));
for stimulus = 1:size(tatd,1)
    
   tatd(stimulus,:) = mean(td( ltd == stimuli(stimulus),:) , 1);
    
end

end

