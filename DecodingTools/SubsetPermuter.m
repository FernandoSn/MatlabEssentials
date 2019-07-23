function Xs = SubsetPermuter(X, Y, samplesize, TypeStack, BinSizes, n_bins)

% Preallocate
SelectBins = cell(size(TypeStack,2),length(BinSizes));
Xs = cell(size(TypeStack,2),length(BinSizes));

for cty = 1:size(TypeStack,2)
    TypeTemp = find(TypeStack{cty});
    if length(TypeTemp)>=samplesize
        SelectCells = TypeTemp(randperm(length(TypeTemp),samplesize));
        for BS = 1:length(BinSizes)
            SelectBins{cty,BS} = bsxfun(@plus,(SelectCells'-1).*n_bins(BS),(1:n_bins(BS))');
            SelectBins{cty,BS} = SelectBins{cty,BS}(:);
            Xs{cty,BS} = X{BS}(:,SelectBins{cty,BS});
            
%                     % Have to reshape the doggone data again becasue of stupid
%                     % shuffling. If you shuffle bins across trials, binned classification
%                     % does better, probably because values are highly correlated within
%                     % a trial for a cell.
%                     b = reshape(Xs{cty,BS},size(Xs{cty,BS},1),n_bins(BS),size(Xs{cty,BS},2)/n_bins(BS));
%                     Xcrs{cty,BS} = mat2cell(b,ones(1,size(b,1)),ones(1,size(b,2)),size(b,3));
%             
%                     % Randomize data across trials of the same stimulus
%                     vlist = unique(Y);
%                     for V = 1:length(vlist)
%                          Xcrs{cty,BS}(Y == vlist(V),:) = shake(Xcrs{cty,BS}(Y == vlist(V),:),1);
%                     end
%             
%                     % Undo the reshaping
%                     a = cell2mat(Xcrs{cty,BS});
%                     Xs{cty,BS} = reshape(permute(a,[1,3,2]),160,[]);
        end
%     else
%         continue
    end
end
end