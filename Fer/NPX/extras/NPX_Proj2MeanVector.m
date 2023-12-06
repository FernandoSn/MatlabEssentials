function SF = NPX_Proj2MeanVector(Raster,PST,Kernelsize,trials)

%[~,~,BigMat] = NPX_Raster2SingleUnitCell(Raster,PST, Kernelsize, trials,1);
[~,~,BigMat] = NPX_Raster2SingleUnitCell(Raster,PST, 0.1, trials,1);
BigMat = zscore(BigMat);
%BigMat = BigMat ./ max(BigMat,1);


timeBins = size(BigMat,1) ./ ( size(Raster,1) * length(trials) );

%%%%%
tt = (PST(end) -PST(1));
kernel = gaussmf(linspace(-tt,tt,timeBins),[Kernelsize 0])';
kernel = kernel ./ sum(kernel);
for ii = 1:size(BigMat,2)
    
    BigMat(:,ii) = conv(BigMat(:,ii),kernel,'same');
    
end
%%%%%
%BigMat = zscore(BigMat);
%BigMat = BigMat ./ max(BigMat,1);




TAPure1 = [];
TAPure2 = [];

for ii = 1:length(trials)
   
    idx1 = 1 + timeBins * ( ii-1 );
    idx2 = idx1+timeBins-1;
    
    TAPure1 = cat(3,TAPure1, BigMat(idx1:idx2,:));
    %TAPure1 = cat(3,TAPure1, conv(BigMat(idx1:idx2,:),kernel,'same'));
    
    idx1 = 1 + size(BigMat,1) - length(trials) * timeBins;
    idx1 = idx1 + timeBins * ( ii-1 );
    idx2 = idx1+timeBins-1;
    
    TAPure2 = cat(3,TAPure2, BigMat(idx1:idx2,:));
    %TAPure2 = cat(3,TAPure2, conv(BigMat(idx1:idx2,:),kernel,'same'));
end

TAPure1 = mean(TAPure1,3);
TAPure2 = mean(TAPure2,3);

for ii = 1:size(TAPure1)
   
    TAPure1(ii,:) = TAPure1(ii,:) ./ norm(TAPure1(ii,:));
    TAPure2(ii,:) = TAPure2(ii,:) ./ norm(TAPure2(ii,:));
    
end


TAPure = TAPure2 - TAPure1;

SF = zeros( timeBins, length(trials) .* size(Raster,1) );

n = 1;
for ii = 1:size(BigMat,1)
    
    %CosSim1 = dot(TAPure1(n,:),BigMat(ii,:))./(norm(TAPure1(n,:))*norm(BigMat(ii,:)));
    %CosSim2 = dot(TAPure2(n,:),BigMat(ii,:))./(norm(TAPure2(n,:))*norm(BigMat(ii,:)));
    
    %CosSim1 = (CosSim1 + 1);
    %CosSim2 = (CosSim2 + 1);
    
    
    SF(ii) = BigMat(ii,:) * (TAPure(n,:) ./ norm(TAPure(n,:)))';
    
    n = n+1;
    if n>timeBins; n = 1; end
    
end