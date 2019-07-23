function [CM, ACC, N, trainedmodel] = GenTaskClassifier(trainlabel, traindata, task)

if nargin<3
    DISTANCE = 'euclidean';
elseif ~isfield(task,'DISTANCE')
    DISTANCE = 'euclidean';
end

if isfield(task,'taskstim')
    num_jobs = length(task.taskstim);
else
    num_jobs = 1;
end

%%
for j = 1:num_jobs
    templabel = trainlabel;
    tempdata = traindata;
    
    templabel = templabel(ismember(trainlabel,task.taskstim{j}),:);
    tempdata = tempdata(ismember(trainlabel,task.taskstim{j}),:);
    
%     tempdata = shake(tempdata,1);
%     templabel = shake(templabel,1);
    obsindex = 1:length(templabel);
    
    for o = obsindex
        trl = templabel(obsindex ~= o);
        trd = tempdata(obsindex~=o,:);
        clslist = unique(trl,'stable');
        
        % classifier has a bug on identical data due to nanmeans of floats
        % being slightly different depending on the number of trials
        % averaged.  we will add noise <<< 1 and
        % >>> than the difference this error (eps is relative accuracy).
        BigDiff = eps*10^4;
        AddedNoise = (rand(size(trd))*BigDiff);
        trd = trd+AddedNoise;
        
        for cls = 1:length(clslist)
            clsmean(cls,:) = nanmean(trd(trl == clslist(cls),:),1);
        end
        
        % a section just for binarizing should usually by commented
%         clsmean = double(clsmean>.5);
%         AddedNoise = (rand(size(clsmean))*BigDiff);
%         clsmean = clsmean+AddedNoise;
        
        
        
        distances = pdist([tempdata(o,:);clsmean],DISTANCE);
        distances = distances(1:length(clslist));
        if isfield(task,'notes')
            if strcmp(task.notes,'NRA') && ismember(find(clslist==templabel(o)),task.fixup{j})
                distances(clslist == templabel(o)) = nan;
            end
        end
        [~, pred(o)] = min(distances);
    end
    
    pred = clslist(pred);
    
    if isfield(task,'fixup')
        tl = templabel(ismember(templabel,clslist(task.fixup{j})));
        pl = pred(ismember(templabel,clslist(task.fixup{j})));
        tl(ismember(tl,clslist(task.fixup{j}))) = -1;
        pl(ismember(pl,clslist(task.fixup{j}))) = -1;
        
        N(j) = length(tl);
        CM{j} = confusionmat(tl,pl);
       
        CM{j} = bsxfun(@rdivide,CM{j},sum(CM{j},2));
        ACC(j) = CM{j}(1,1);
        
        CM{j} = confusionmat(templabel,pred);
        CM{j} = [sum(CM{j}(:,task.fixup{j}),2), CM{j}(:,~ismember(1:size(CM{j},2),task.fixup{j}))];
        CM{j} = CM{j}(task.fixup{j},:);
        CM{j} = bsxfun(@rdivide,CM{j},sum(CM{j},2));

%         ACC(j) = mean(CM{j}(:,1));

    else
        CM{j} = confusionmat(templabel,pred);
        CM{j} = bsxfun(@rdivide,CM{j},sum(CM{j},2));
        ACC(j) = mean(diag(CM{j}));
        N(j) = length(templabel);
    end
end

N = sum(N);
ACC = mean(ACC);

%% train on all data for crossing with other data sets.
clslist = unique(trainlabel);
for cls = 1:length(clslist)
    trainedmodel(cls,:) = nanmean(traindata(trainlabel == clslist(cls),:),1);
end

% trainedmodel = trainedmodel(task.taskstim{j},:); 
% turned off 04/28/18..
% sorry

end

