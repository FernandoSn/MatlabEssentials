function Ztraindata = NPX_GetZScoredPseudoMat(traindata,baseline,label)

label(:) = 1;

Ztraindata = [];

Odors = unique(label);




for ii = 1:length(Odors)   
   x = baseline(label == Odors(ii),:);
   y = traindata(label == Odors(ii),:);
   ave = mean(x);
   sdev = sqrt(sum((x - mean(x)).^2) ./ length(x));
   %sdev = std(x);
   %sdev(sdev==0) = 1;
   
   Ztraindata = [Ztraindata; (y - ave)./sdev];
   %Ztraindata = [Ztraindata; (y - ave)]; 
end


badcell = any(isinf(Ztraindata) | isnan(Ztraindata));
% fprintf('Badcells: %d \n', sum(badcell))
Ztraindata(:,badcell) = [];
