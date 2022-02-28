function [DistanceMat,score,DistErr,DistAve,DistMatNorm,DistNormErr] = NPX_NeuralDistance(traindata,Odors,method,NumPC,varargin)



if ~isempty(varargin)
    isplot = varargin{1};
else
    isplot = false;
end
if length(varargin) > 1
    blocks = varargin{2};
else
    blocks = 1;
end



%traindata = traindata(size(traindata,1)/(Odors) + 1:end,:);
%Odors = Odors - 1;

if strcmp(method, 'pca')
    
    
%     traindata = traindata';
%     
%     traindata = (traindata - mean(traindata,1))./ std(traindata);
%     traindata(isnan(traindata)) = 0;
%     traindata(isinf(traindata)) = 0;
%     
%     traindata = traindata';
    
    %NumPC = 2;
    %traindata  = zscore(traindata);
    [~,score,~,~,explained] = pca(traindata);
    
%     score = score';
%     
%     score = (score - mean(score,1))./ std(score);
%     score(isnan(score)) = 0;
%     score(isinf(score)) = 0;
    
    score = zscore(score);
%     
%     score = score';

% Use time as PC3
%     for ii = 1:Trials:size(traindata,1)
%        
%         score(ii:ii+Trials-1,3) = 1:Trials;
% 
%     end
    
    
elseif strcmp(method,'umap')
        
    %NumPC = 3;
    %score = run_umap(traindata,'metric','cosine','n_components',NumPC,'verbose','none');
    %score = run_umap(traindata,'min_dist',0.09,'n_neighbors',3,'n_components',NumPC,'verbose','none');
    score = run_umap(traindata,'metric','cosine','min_dist',0.09,'n_neighbors',15,'n_components',NumPC,'verbose','none');
    
elseif strcmp(method,'tsne')
    
    rng('default') 
    score = tsne(traindata,'Algorithm','barneshut','NumDimensions',NumPC,'Distance','correlation');
    %score = tsne(traindata,'NumDimensions',NumPC);
    
else
    
    NumPC = size(traindata,2);
    score = traindata;
    
end


BinsNo = size(score,1) / Odors / blocks; %BinsNo can be time bins of am averaged vector or actual trials.

DistanceMat = zeros(BinsNo,Odors);



for ii = 1:BinsNo
    
    for kk = 0:Odors-2
       
        %Vec1 = score(kk * Trials + ii,1:NumPC);
        Vec1 = score(ii,1:NumPC);
        Vec2 = score((kk + 1) * BinsNo + ii,1:NumPC);
        
        %DistanceMat(ii,kk+2) = DistanceMat(ii,kk+1) + norm(Vec1-Vec2);
        DistanceMat(ii,kk+2) = norm(Vec1-Vec2);
        
        
%         %Vec1 = score(kk * Trials + ii,1:NumPC);
%         Vec1 = traindata(ii,:);
%         Vec2 = traindata((kk + 1) * BinsNo + ii,:);
%         
%         %DistanceMat(ii,kk+2) = DistanceMat(ii,kk+1) + norm(Vec1-Vec2);
%         DistanceMat(ii,kk+2) = norm(Vec1-Vec2);
        
    end
    
end

DistAve = mean(DistanceMat,1);
DistErr = std(DistanceMat) ./ sqrt(BinsNo);

DistMatNorm = DistanceMat ./ max(DistanceMat,[],2);
DistAve = mean(DistMatNorm,1);
DistNormErr = std(DistMatNorm) ./ sqrt(BinsNo);

len = BinsNo * Odors;
if(isplot)
    for ii = 1:blocks

        
        temp = score(((ii-1) * len)+1 : ii * len,1:NumPC);
        %NPX_ScatterPlot(temp,BinsNo,true,true,round(explained(1:NumPC)));
        NPX_ScatterPlot(temp,BinsNo,true,true,[]);

    end
end

% for kk = 0:Odors-2
%        
%     ini1 = kk*Trials+1;
%     ini2 = (kk+1)*Trials+1;
%     
%     %Vec1 = mean(score(ini1 : ini1 + Trials - 1,1:NumPC),1);
%     
%     Vec1 = mean(score(1 : Trials,1:NumPC),1);
%     
%     Vec2 = mean(score(ini2 : ini2 + Trials - 1,1:NumPC),1);
%     
%     DistAve(kk+2) = norm(Vec1-Vec2);
%     
%     %DistAve(kk+2) = DistAve(kk+1) + norm(Vec1-Vec2);
%         
% end

